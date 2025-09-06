import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    setState(() {
      _acceptedTerms = accepted;
    });

    if (!accepted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTermsDialog();
      });
    } else {
      _initializePage();
    }
  }

  Future<void> _saveAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('acceptedTerms', true);
  }

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

  void _showTermsDialog() {
    bool tempAccepted = false;
    const String termoFormal = """
      TERMO DE CONSCIENTIZAÇÃO E ISENÇÃO DE RESPONSABILIDADE
      
      Ao utilizar esta aplicação, o USUÁRIO declara que está ciente e de acordo com as condições abaixo:
      
      1. ORIGEM DAS INFORMAÇÕES
      Todas as ofertas, preços, promoções, produtos e demais informações disponibilizadas nesta plataforma são de responsabilidade exclusiva dos ESTABELECIMENTOS ANUNCIANTES. Esta aplicação atua unicamente como ferramenta de divulgação, não sendo autora, editora ou responsável pelo conteúdo veiculado nos panfletos ou anúncios exibidos.
      
      2. POSSÍVEIS DIVERGÊNCIAS
      As informações apresentadas podem conter erros de digitação, falhas de atualização ou divergências em relação às condições praticadas pelos estabelecimentos. Em caso de dúvida, recomenda-se que o usuário sempre confirme as informações diretamente com o ESTABELECIMENTO ANUNCIANTE antes de efetivar qualquer compra.
      
      3. LIMITAÇÃO DE RESPONSABILIDADE
      Esta aplicação não se responsabiliza, em hipótese alguma, por prejuízos, danos ou perdas de qualquer natureza decorrentes da utilização das informações divulgadas, sejam eles diretos ou indiretos. Cabe exclusivamente ao USUÁRIO verificar a veracidade, disponibilidade e condições das ofertas apresentadas.
      
      4. ACEITAÇÃO
      Ao prosseguir com o uso desta aplicação, o USUÁRIO declara que leu, compreendeu e aceitou integralmente este termo, isentando a plataforma e seu responsável legal de qualquer responsabilidade sobre o conteúdo dos anúncios divulgados.
    """;


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                "Termo de Conscientização",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: termoFormalWidget(),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: tempAccepted,
                          onChanged: (value) {
                            setStateDialog(() {
                              tempAccepted = value ?? false;
                            });
                            if (value == true) {
                              setState(() {
                                _acceptedTerms = true;
                              });
                              _saveAcceptedTerms();
                              Navigator.of(context).pop();
                              _initializePage();
                            }
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Li e aceito os termos",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget termoFormalWidget() {
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
        children: [
          TextSpan(
            text: "TERMO DE CONSCIENTIZAÇÃO E ISENÇÃO DE RESPONSABILIDADE\n\n",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextSpan(
            text: "Ao utilizar esta aplicação, o USUÁRIO declara que está ciente e de acordo com as condições abaixo:\n\n",
          ),
          TextSpan(
            text: "1. ORIGEM DAS INFORMAÇÕES\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
            "Todas as ofertas, preços, promoções, produtos e demais informações disponibilizadas nesta plataforma são de responsabilidade exclusiva dos ESTABELECIMENTOS ANUNCIANTES. Esta aplicação atua unicamente como ferramenta de divulgação, não sendo autora, editora ou responsável pelo conteúdo veiculado nos panfletos ou anúncios exibidos.\n\n",
          ),
          TextSpan(
            text: "2. POSSÍVEIS DIVERGÊNCIAS\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
            "As informações apresentadas podem conter erros de digitação, falhas de atualização ou divergências em relação às condições praticadas pelos estabelecimentos. Em caso de dúvida, recomenda-se que o usuário sempre confirme as informações diretamente com o ESTABELECIMENTO ANUNCIANTE antes de efetivar qualquer compra.\n\n",
          ),
          TextSpan(
            text: "3. LIMITAÇÃO DE RESPONSABILIDADE\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
            "Esta aplicação não se responsabiliza, em hipótese alguma, por prejuízos, danos ou perdas de qualquer natureza decorrentes da utilização das informações divulgadas, sejam eles diretos ou indiretos. Cabe exclusivamente ao USUÁRIO verificar a veracidade, disponibilidade e condições das ofertas apresentadas.\n\n",
          ),
          TextSpan(
            text: "4. ACEITAÇÃO\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
            "Ao prosseguir com o uso desta aplicação, o USUÁRIO declara que leu, compreendeu e aceitou integralmente este termo, isentando a plataforma e seu responsável legal de qualquer responsabilidade sobre o conteúdo dos anúncios divulgados.",
          ),
        ],
      ),
    );
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
        appBar: appBar(),
        body: Center(
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
      gridPadding = EdgeInsets.symmetric(horizontal: 120.0);
    } else if (screenWidth > tabletBreakpoint) {
      gridPadding = EdgeInsets.symmetric(horizontal: 90.0);
    } else {
      gridPadding = EdgeInsets.only(left: 15.0, right: 15.0);
    }

    EdgeInsets textFieldPadding;
    if (screenWidth > tabletBreakpoint) {
      textFieldPadding =
          EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0);
    } else {
      textFieldPadding = EdgeInsets.only(left: 5.0, right: 5.0, top: 40.0);
    }

    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          Container(
            margin: textFieldPadding,
            child: SearchBar(
              hintText: 'Digite o nome do produto',
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