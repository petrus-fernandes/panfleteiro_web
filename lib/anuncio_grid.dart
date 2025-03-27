import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'my_flutter_app_icons.dart';

import 'anuncio.dart';

class AnuncioGrid extends StatelessWidget {
  final List<Anuncio> anuncios;
  final int crossAxisCount; // Número de colunas
  final double fixedHeight; // Altura fixa dos cards

  const AnuncioGrid({
    Key? key,
    required this.anuncios,
    required this.crossAxisCount,
    required this.fixedHeight,
  }) : super(key: key);

  void _showAnuncioModal(BuildContext context, Anuncio anuncio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnuncioModal(anuncio: anuncio),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile =
        screenWidth < 800; // Define mobile como telas menores que 800px
    final formatter = NumberFormat.currency(
      locale: "pt-BR",
      symbol: "R\$ ",
      decimalDigits: 2,
    );

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(), // Desabilita o scroll interno
      shrinkWrap: true, // Importante para funcionar dentro do CustomScrollView
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 8.0 : 60.0,
        mainAxisSpacing: isMobile ? 8.0 : 30.0,
        childAspectRatio: (screenWidth / crossAxisCount) / fixedHeight,
      ),
      itemCount: anuncios.length,
      itemBuilder: (context, index) {
        final anuncio = anuncios[index];
        return GestureDetector(
          onTap: () => _showAnuncioModal(context, anuncio),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: fixedHeight,
              padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.5),
                    Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.2),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Nome do produto
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      anuncio.nome,
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 40, // Fonte menor no mobile
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Preço no canto inferior esquerdo
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Text(
                      formatter.format(anuncio.preco),
                      style: TextStyle(
                        fontSize: isMobile ? 30 : 50, // Fonte menor no mobile
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  // Validade e distância no canto inferior direito
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (anuncio.dataValidade != null)
                          Text(
                            'Validade: ${DateFormat('dd/MM/yyyy').format(anuncio.dataValidade!)}',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              // Fonte menor no mobile
                              color: Colors.grey[600],
                            ),
                          ),
                        if (anuncio.distancia != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 1.0),
                            child: RichText(
                              text: TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Icon(
                                      MyFlutterApp.marker,
                                      size: isMobile ? 10 : 12,
                                      // Ícone menor no mobile
                                      color: Colors.grey[600],
                                    ),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                  TextSpan(
                                    text: ' Distância: ',
                                    style: TextStyle(
                                      fontSize: isMobile ? 10 : 12,
                                      // Fonte menor no mobile
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  TextSpan(
                                    text: anuncio.distanciaText(),
                                    style: TextStyle(
                                      fontSize: isMobile ? 10 : 12,
                                      // Fonte menor no mobile
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _distanciaText(Anuncio anuncio) {
    if (anuncio.distancia == null) {
      return '';
    }

    if (anuncio.distancia! < 1) {
      String? distanceBasicFormat = anuncio.distancia?.toStringAsFixed(3);
      double distanceBasicFormatDouble = double.parse(distanceBasicFormat!);
      return '${distanceBasicFormatDouble * 1000} m';
    }
    return '${_parseDecimalWithThreeDigits(anuncio.distancia)} km';
  }

  static String _parseDecimalWithThreeDigits(distance) {
    return NumberFormat('#,##0.000', 'pt-BR').format(distance);
  }
}

class AnuncioModal extends StatelessWidget {
  final Anuncio anuncio;

  const AnuncioModal({Key? key, required this.anuncio}) : super(key: key);

  Future<void> _openGoogleMaps() async {
    if (anuncio.latitude == null || anuncio.longitude == null) return;

    final url =
        'https://www.google.com/maps/search/?api=1&query=${anuncio.latitude},${anuncio.longitude}';
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Cabeçalho do modal
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ],
          ),

          // Conteúdo
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    anuncio.nome,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Preço com destaque
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          NumberFormat.currency(
                            locale: "pt-BR",
                            symbol: "R\$ ",
                          ).format(anuncio.preco),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (anuncio.dataValidade != null) ...[
                    SizedBox(height: 10),
                    Text(
                      'Validade: ${DateFormat('dd/MM/yyyy').format(anuncio.dataValidade!)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                  if (anuncio.distancia != null) ...[
                    SizedBox(height: 10),
                    Text(
                      'Distância: ${anuncio.distanciaText()}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],

                  if (anuncio.marketName != null) ...[
                    SizedBox(height: 10),
                    Text(
                      'Mercado: ${anuncio.marketName}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],

                  if (anuncio.marketAddress != null) ...[
                    SizedBox(height: 10),
                    Text(
                      'Endereço: ${anuncio.marketAddress}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                  SizedBox(height: 20),

                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child:
                        anuncio.latitude != null && anuncio.longitude != null
                            ? Image.network(
                                'https://maps.googleapis.com/maps/api/staticmap?center=${anuncio.latitude},${anuncio.longitude}&zoom=15&size=1000x400&maptype=roadmap&markers=color:red%7C${anuncio.latitude},${anuncio.longitude}&key=${dotenv.env['GOOGLE_API_KEY']}',
                                fit: BoxFit.cover,
                                headers: {'Accept': 'image/*'},
                                // Adicione headers para melhor compatibilidade
                                loadingBuilder:
                                    (_, child, progress) =>
                                        progress == null
                                            ? child
                                            : Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                errorBuilder:
                                    (_, __, ___) => Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error, color: Colors.red),
                                          Text('Falha ao carregar o mapa'),
                                        ],
                                      ),
                                    ),
                              )

                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_off, size: 40),
                                  Text('Localização indisponível'),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),
          if (anuncio.latitude != null && anuncio.longitude != null)
            FilledButton.tonal(
              onPressed: _openGoogleMaps,
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map),
                  SizedBox(width: 8),
                  Text('Abrir no Google Maps'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
