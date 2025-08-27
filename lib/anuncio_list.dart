import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';
import 'anuncio_grid.dart';
import 'anuncio_service.dart';
import 'anuncio.dart';

class AnuncioList extends StatefulWidget {
  @override
  _AnuncioListState createState() => _AnuncioListState();
}

class _Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class _AnuncioListState extends State<AnuncioList> {
  int _page = 0;
  final int _size = 10;
  List<Anuncio> _anuncios = [];
  bool _isLoading = false;
  String _searchTerm = '';
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isSearchActive = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;
  final _Debouncer _scrollDebouncer = _Debouncer(milliseconds: 500);
  bool _locationAllowed = false;

  Future<void> _initializePage() async {
    try {
      await _getUserLocation();
      setState(() {
        _locationAllowed = true;
        _isSearchActive = true;
      });
    } catch (e) {
      print("Localização não disponível: $e");
      setState(() {
        _locationAllowed = false;
        _isSearchActive = false;
      });
    }

    await _loadAnuncios();
  }

  Future<void> _loadAnuncios({bool isNewSearch = false}) async {
    if (isNewSearch) {
      setState(() {
        _page = 0;
        _anuncios.clear();
        _hasMore = true;
        _isSearchActive = _locationAllowed;
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      List<Anuncio> newAnuncios;

      if (_isSearchActive && _locationAllowed) {
        newAnuncios = await Provider.of<AnuncioService>(
          context,
          listen: false,
        ).fetchAnunciosPorLocalizacao(
            _latitude, _longitude, _searchTerm, _page, _size);
      } else {
        newAnuncios = await Provider.of<AnuncioService>(
          context,
          listen: false,
        ).fetchAnunciosPorNome(_searchTerm, _page, _size);
      }

      setState(() {
        _anuncios.addAll(newAnuncios);
        _page++;
        _hasMore = newAnuncios.length >= _size;
      });
    } catch (e) {
      print('Erro ao carregar anúncios: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Serviço de localização desativado';

    await validateGeolocatorPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> validateGeolocatorPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permissão de localização negada';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Permissão de localização permanentemente negada';
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _initializePage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    _scrollDebouncer.run(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 100 &&
          !_isLoading &&
          _hasMore) {
        _loadAnuncios();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    const double webBreakpoint = 1350;
    const double tabletBreakpoint = 800;

    int crossAxisCount;
    if (screenWidth > webBreakpoint) {
      crossAxisCount = 3; // Web: 3 colunas
    } else if (screenWidth > tabletBreakpoint) {
      crossAxisCount = 2; // Tablet: 2 colunas
    } else {
      crossAxisCount = 1; // Mobile: 1 coluna
    }

    // Define a altura fixa dos cards
    final fixedHeight = screenWidth > tabletBreakpoint ? 250.0 : 150.0;

    // Define o gridPadding com base no dispositivo
    EdgeInsets gridPadding;
    if (screenWidth > webBreakpoint) {
      gridPadding = EdgeInsets.symmetric(horizontal: 120.0);
    } else if (screenWidth > tabletBreakpoint) {
      gridPadding = EdgeInsets.symmetric(horizontal: 90.0);
    } else {
      gridPadding = EdgeInsets.only(left: 15.0, right: 15.0);
    }

    //
    EdgeInsets textFieldPadding;
    if (screenWidth > tabletBreakpoint) {
      textFieldPadding = EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0); // Web/Tablet
    } else {
      textFieldPadding = EdgeInsets.only(left: 5.0, right: 5.0, top: 40.0); // Mobile
    }

    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          Container(
            margin: textFieldPadding,
            child: SearchBar(
              hintText: 'Digite o nome do produto',
              hintStyle: MaterialStateProperty.all(
                TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              leading: Icon(Icons.search),
              elevation: MaterialStateProperty.all(1),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) {
                _searchTerm = value;
              },
              onSubmitted: (value) async {
                _searchTerm = value;

                if (!_locationAllowed) {
                  try {
                    await _getUserLocation();
                    setState(() {
                      _locationAllowed = true;
                      _isSearchActive = true;
                    });
                  } catch (e) {
                    print("Usuário não permitiu localização na busca: $e");
                    setState(() {
                      _locationAllowed = false;
                      _isSearchActive = false;
                    });
                  }
                }

                _loadAnuncios(isNewSearch: true);
              },
            ),
          ),

          SizedBox(height: 50),

          Expanded(
            child: Padding(
              padding: gridPadding,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollUpdateNotification &&
                      _scrollController.position.pixels >
                          _scrollController.position.maxScrollExtent - 500 &&
                      !_isLoading &&
                      _hasMore) {
                    _loadAnuncios();
                  }
                  return false;
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: AnuncioGrid(
                        anuncios: _anuncios,
                        crossAxisCount: crossAxisCount,
                        fixedHeight: fixedHeight,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _isLoading
                          ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : SizedBox.shrink(),
                    ),
                    SliverToBoxAdapter(
                      child: !_hasMore && _anuncios.isNotEmpty
                          ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Todos os itens foram carregados',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  appBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/main');
            },
            child: Image.asset(
              'assets/logo.png',
              height: 65,
            ),
          ),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text(
              'Mercadão',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            icon: Icon(Icons.login),
            label: Text('Login'),
          ),
        ),
      ],
    );
  }

}