import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'my_flutter_app_icons.dart';

import 'anuncio.dart';

class AnuncioGrid extends StatelessWidget {
  final List<Anuncio> anuncios;
  final int crossAxisCount; // Número de colunas
  final double fixedHeight; // Altura fixa dos cards

  AnuncioGrid({
    required this.anuncios,
    required this.crossAxisCount,
    required this.fixedHeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800; // Define mobile como telas menores que 800px
    final formatter = NumberFormat.currency(
      locale: "pt-BR",
      symbol: "R\$ ",
      decimalDigits: 2,
    );

    return GridView.builder(
      padding: EdgeInsets.zero, // Remove o padding interno do GridView
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // Número de colunas
        crossAxisSpacing: isMobile ? 8.0 : 60.0, // Espaçamento entre colunas
        mainAxisSpacing: isMobile ? 8.0 : 30.0, // Espaçamento entre linhas
        childAspectRatio: (screenWidth / crossAxisCount) / fixedHeight, // Proporção ajustada
      ),
      itemCount: anuncios.length,
      itemBuilder: (context, index) {
        final anuncio = anuncios[index];
        return Card(
          child: Container(
            height: fixedHeight, // Altura fixa
            padding: EdgeInsets.all(isMobile ? 8.0 : 15.0), // Padding menor no mobile
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
                            fontSize: isMobile ? 10 : 12, // Fonte menor no mobile
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
                                    size: isMobile ? 10 : 12, // Ícone menor no mobile
                                    color: Colors.grey[600],
                                  ),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                                TextSpan(
                                  text: ' Distância: ',
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 12, // Fonte menor no mobile
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextSpan(
                                  text: _distanciaText(anuncio),
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 12, // Fonte menor no mobile
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