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
  bool _isSearchActive = false; // Controla se uma busca está ativa

  Future<void> _loadAnuncios({bool isNewSearch = false}) async {
    if (isNewSearch) {
      // Se for uma nova busca, reseta a página e limpa a lista
      setState(() {
        _page = 0;
        _anuncios.clear();
        _isSearchActive = true; // Ativa a busca
      });
    }

    setState(() {
      _isLoading = true;
    });

    print('Carregando página: $_page'); // Log para depuração

    try {
      // Verifica se a busca está ativa e se a localização é necessária
      if (_isSearchActive) {
        // Obtém a localização do usuário
        await _getUserLocation();
      }

      List<Anuncio> newAnuncios;
      if (_isSearchActive) {
        // Se uma busca está ativa, carrega mais itens da busca
        newAnuncios = await Provider.of<AnuncioService>(
          context,
          listen: false,
        ).fetchAnunciosPorLocalizacao(
            _latitude, _longitude, _searchTerm, _page, _size);
      } else {
        // Caso contrário, carrega mais itens da lista inicial
        newAnuncios = await Provider.of<AnuncioService>(
          context,
          listen: false,
        ).fetchAnunciosPorNome(_searchTerm, _page, _size);
      }

      print('Novos anúncios carregados: ${newAnuncios.length}'); // Log para depuração

      // Verifica se há novos anúncios antes de adicionar
      if (newAnuncios.isNotEmpty) {
        setState(() {
          _anuncios.addAll(newAnuncios); // Adiciona os novos anúncios à lista
          _page++; // Incrementa a página para o próximo carregamento
        });
      } else {
        setState(() {
          // Não há mais itens para carregar
        });
      }
    } catch (e) {
      print('Erro ao carregar anúncios: $e'); // Log para depuração
    } finally {
      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento
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

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAnuncios(); // Carrega os anúncios iniciais
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints para web, tablet e mobile
    const double webBreakpoint = 1350;
    const double tabletBreakpoint = 800;

    // Define o número de colunas com base na largura da tela
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

    // Define o padding com base no dispositivo
    EdgeInsets padding;
    if (screenWidth > webBreakpoint) {
      padding = EdgeInsets.symmetric(horizontal: 120.0); // Web: margens laterais
    } else if (screenWidth > tabletBreakpoint) {
      padding = EdgeInsets.symmetric(horizontal: 60.0); // Tablet: margens menores
    } else {
      padding = EdgeInsets.only(right: 70.0); // Mobile: apenas margem direita
    }

    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0),
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
                _loadAnuncios(isNewSearch: true); // Nova busca
              },
            ),
          ),
          SizedBox(height: 50),
          Expanded(
            child: Padding(
              padding: padding, // Usa o padding definido com base no dispositivo
              child: AnuncioGrid(
                anuncios: _anuncios,
                crossAxisCount: crossAxisCount, // Passa o número de colunas
                fixedHeight: fixedHeight, // Passa a altura fixa dos cards
              ),
            ), // Usa o AnuncioGrid aqui
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () => _loadAnuncios(), // Carrega mais itens
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