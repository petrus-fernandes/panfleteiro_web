import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/anuncio_app_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/termos_dialog.dart';
import '../utils/debouncer.dart';
import '../utils/constants.dart';
import '../services/location_service.dart';
import '../services/anuncio_service.dart';
import '../models/anuncio.dart';
import '../widgets/anuncio_grid.dart';

class AnuncioMainScreen extends StatefulWidget {
  const AnuncioMainScreen({super.key});

  @override
  State<AnuncioMainScreen> createState() => _AnuncioMainScreenState();
}

class _AnuncioMainScreenState extends State<AnuncioMainScreen> {
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
  final Debouncer _scrollDebouncer = Debouncer(milliseconds: 500);
  bool _locationAllowed = false;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _checkAcceptedTerms();
  }

  Future<void> _checkAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('acceptedTerms') ?? false;
    final acceptedDateStr = prefs.getString('acceptedTermsDate');
    final acceptedVersion = prefs.getString('acceptedTermsVersion') ?? "";

    bool isValid = false;

    if (accepted && acceptedDateStr != null) {
      final acceptedDate = DateTime.tryParse(acceptedDateStr);
      if (acceptedDate != null) {
        final difference = DateTime.now().difference(acceptedDate).inDays;
        isValid = difference < AppConstants.termDays &&
            acceptedVersion == AppConstants.termVersion;
      }
    }

    setState(() {
      _acceptedTerms = isValid;
    });

    if (!isValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => TermosDialog(onAccepted: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('acceptedTerms', true);
            await prefs.setString(
                'acceptedTermsDate', DateTime.now().toIso8601String());
            await prefs.setString(
                'acceptedTermsVersion', AppConstants.termVersion);
            setState(() {
              _acceptedTerms = true;
            });
            _initializePage();
          }),
        );
      });
    } else {
      _initializePage();
    }
  }

  Future<void> _initializePage() async {
    try {
      final location = await LocationService().getUserLocation();
      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        _locationAllowed = true;
        _isSearchActive = true;
      });
    } catch (e) {
      debugPrint("Localização não disponível: $e");
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
      debugPrint('Erro ao carregar anúncios: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_acceptedTerms) {
      return Scaffold(
        appBar: const AnuncioAppBar(),
        body: const Center(
          child: Text("É necessário aceitar os termos para continuar"),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    const double webBreakpoint = 1350;
    const double tabletBreakpoint = 800;

    int crossAxisCount;
    if (screenWidth > webBreakpoint) {
      crossAxisCount = 3;
    } else if (screenWidth > tabletBreakpoint) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    final fixedHeight = screenWidth > tabletBreakpoint ? 250.0 : 150.0;

    EdgeInsets gridPadding;
    if (screenWidth > webBreakpoint) {
      gridPadding = const EdgeInsets.symmetric(horizontal: 120.0);
    } else if (screenWidth > tabletBreakpoint) {
      gridPadding = const EdgeInsets.symmetric(horizontal: 90.0);
    } else {
      gridPadding = const EdgeInsets.only(left: 15.0, right: 15.0);
    }

    EdgeInsets textFieldPadding;
    if (screenWidth > tabletBreakpoint) {
      textFieldPadding =
      const EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0);
    } else {
      textFieldPadding =
      const EdgeInsets.only(left: 5.0, right: 5.0, top: 40.0);
    }

    return Scaffold(
      appBar: const AnuncioAppBar(),
      body: Column(
        children: [
          Container(
            margin: textFieldPadding,
            child: SearchBarWidget(
              onChanged: (value) => _searchTerm = value,
              onSubmitted: (value) async {
                _searchTerm = value;
                if (!_locationAllowed) {
                  try {
                    final location = await LocationService().getUserLocation();
                    setState(() {
                      _latitude = location.latitude;
                      _longitude = location.longitude;
                      _locationAllowed = true;
                      _isSearchActive = true;
                    });
                  } catch (e) {
                    debugPrint("Usuário não permitiu localização na busca: $e");
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
          const SizedBox(height: 50),
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
                          ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                    SliverToBoxAdapter(
                      child: !_hasMore && _anuncios.isNotEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(16.0),
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
                          : const SizedBox.shrink(),
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
}
