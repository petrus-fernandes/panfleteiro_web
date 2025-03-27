import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';
import 'anuncio_grid.dart';
import 'anuncio_service.dart';
import 'anuncio.dart';

class AnuncioList extends StatefulWidget {
  @override
  _AnuncioListState createState() => _AnuncioListState();
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

  Future<void> _loadAnuncios({bool isNewSearch = false}) async {
    if (isNewSearch) {
      setState(() {
        _page = 0;
        _anuncios.clear();
        _isSearchActive = true;
      });
    }

    setState(() {
      _isLoading = true;
    });

    print('Carregando página: $_page');

    try {
      if (_isSearchActive) {
        await _getUserLocation();
      }

      List<Anuncio> newAnuncios;
      if (_isSearchActive) {
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

      print('Novos anúncios carregados: ${newAnuncios.length}');

      if (newAnuncios.isNotEmpty) {
        setState(() {
          _anuncios.addAll(newAnuncios);
          _page++;
        });
      } else {
        setState(() {
        });
      }
    } catch (e) {
      print('Erro ao carregar anúncios: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAnuncios();
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
      gridPadding = EdgeInsets.only(right: 70.0);
    }

    EdgeInsets textFieldPadding;
    if (screenWidth > tabletBreakpoint) {
      textFieldPadding = EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0); // Web/Tablet
    } else {
      textFieldPadding = EdgeInsets.only(left: 0.0, right: 15.0, top: 40.0); // Mobile
    }

    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          Container(
            margin: textFieldPadding,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xff1D1617).withOpacity(0.11),
                  spreadRadius: 0,
                  blurRadius: 50,
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15.0),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SvgPicture.asset('assets/icons/search.svg'),
                ),
                hintText: 'Digite o nome do produto',
                hintStyle: TextStyle(
                  color: Color(0xffDDDADA),
                  fontSize: 14.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _searchTerm = value;
              },
              onSubmitted: (value) {
                // Realiza a busca quando o usuário pressiona "Enter"
                _loadAnuncios(isNewSearch: true);
              },
            ),
          ),
          SizedBox(height: 50),
          Expanded(
            child: Padding(
              padding: gridPadding,
              child: AnuncioGrid(
                anuncios: _anuncios,
                crossAxisCount: crossAxisCount,
                fixedHeight: fixedHeight,
              ),
            ),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () => _loadAnuncios(),
              child: Text('Carregar mais'),
            ),
        ],
      ),
    );
  }

  appBar() {
    return AppBar(
      title: Text(
        'Mercadão',
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 1.0,
    );
  }
}