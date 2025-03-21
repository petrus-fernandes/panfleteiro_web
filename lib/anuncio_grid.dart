import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'my_flutter_app_icons.dart';

import 'anuncio.dart';

class AnuncioGrid extends StatelessWidget {
  final List<Anuncio> anuncios;

  AnuncioGrid({required this.anuncios});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formatter = NumberFormat.currency(
      locale: "pt-BR",
      symbol: "R\$ ",
      decimalDigits: 2,
    );

    // Define o número de colunas com base na largura da tela
    int crossAxisCount;
    if (screenWidth > 1350) {
      crossAxisCount = 3; // Telas grandes (monitores)
    } else if (screenWidth > 800) {
      crossAxisCount = 2; // Telas médias (tablets)
    } else {
      crossAxisCount = 1; // Telas pequenas (mobile)
    }

    // Altura fixa desejada
    final fixedHeight = 250.0;

    // Calcula a proporção com base na largura da tela e altura fixa
    final childAspectRatio = (screenWidth / crossAxisCount) / fixedHeight;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 60.0,
        mainAxisSpacing: 30.0,
        childAspectRatio: childAspectRatio, // Proporção ajustada dinamicamente
      ),
      itemCount: anuncios.length,
      itemBuilder: (context, index) {
        final anuncio = anuncios[index];
        return Card(
          child: Container(
            height: fixedHeight, // Altura fixa
            padding: EdgeInsets.all(15.0),
            child: Stack(
              children: [
                // Nome do produto
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    anuncio.nome,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
                      fontSize: 50,
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
                            fontSize: 12,
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
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                                TextSpan(
                                  text: ' Distância: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextSpan(
                                  text: _distanciaText(anuncio),
                                  style: TextStyle(
                                    fontSize: 12,
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