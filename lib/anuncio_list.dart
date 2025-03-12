import 'package:flutter/material.dart';
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

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _anuncios.clear();
      _page = 0;
    });

    try {
      final newAnuncios = await Provider.of<AnuncioService>(context, listen: false)
          .fetchAnunciosPorNome(_searchTerm, _page, _size);

      setState(() {
        _anuncios.addAll(newAnuncios); // Adiciona os novos anúncios à lista
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento em caso de erro
      });
      print('Erro na busca: $e');
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

    final newAnuncios = await Provider.of<AnuncioService>(context, listen: false).fetchAnunciosPorNome(_searchTerm, _page, _size);

    setState(() {
      _anuncios.addAll(newAnuncios);
      _isLoading = false;
      _page++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anuncios'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar produto',
              hintText: 'Digite o nome do produto',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
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
}