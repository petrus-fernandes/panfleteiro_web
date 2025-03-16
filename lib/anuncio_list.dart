import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';
import 'anuncio_grid.dart';
import 'anuncio_service.dart';
import 'anuncio.dart';
import 'package:intl/intl.dart';

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

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _anuncios.clear();
      _page = 0;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await Geolocator.getCurrentPosition().then((position) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      });

      try {
        final newAnuncios = await Provider.of<AnuncioService>(
          context,
          listen: false,
        ).fetchAnunciosPorLocalizacao(
            _latitude, _longitude, _searchTerm, _page, _size);

        setState(() {
          _anuncios.addAll(newAnuncios); // Adiciona os novos anúncios à lista
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading =
          false; // Desativa o indicador de carregamento em caso de erro
        });
        print('Erro na busca: $e');
      }
    } else {
      try {
        final newAnuncios = await Provider.of<AnuncioService>(
          context,
          listen: false,
        ).fetchAnunciosPorNome(_searchTerm, _page, _size);

        setState(() {
          _anuncios.addAll(newAnuncios); // Adiciona os novos anúncios à lista
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading =
          false; // Desativa o indicador de carregamento em caso de erro
        });
        print('Erro na busca: $e');
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _loadAnuncios();
  }

  void _loadAnuncios() async {
    setState(() {
      _isLoading = true;
    });

    final newAnuncios = await Provider.of<AnuncioService>(
      context,
      listen: false,
    ).fetchAnunciosPorNome(_searchTerm, _page, _size);

    setState(() {
      _anuncios.addAll(newAnuncios);
      _isLoading = false;
      _page++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
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
                // Atualiza o termo de busca
                _searchTerm = value;
              },
              onSubmitted: (value) {
                // Realiza a busca quando o usuário pressiona "Enter"
                _performSearch();
              },
            ),
          ),
          SizedBox(height: 4),
          Expanded(
            child: AnuncioGrid(anuncios: _anuncios), // Usa o AnuncioGrid aqui
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _loadAnuncios,
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
