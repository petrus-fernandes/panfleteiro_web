import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'my_flutter_app_icons.dart';

import 'anuncio.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'my_flutter_app_icons.dart';

import 'anuncio.dart';

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
    final fixedHeight = screenWidth > tabletBreakpoint ? 250.0 : 300.0;

    // Define o padding com base no dispositivo
    EdgeInsets padding;
    if (screenWidth > webBreakpoint) {
      padding = EdgeInsets.symmetric(horizontal: 120.0); // Web: margens laterais
    } else if (screenWidth > tabletBreakpoint) {
      padding = EdgeInsets.symmetric(horizontal: 60.0); // Tablet: margens menores
    } else {
      padding = EdgeInsets.only(right: 16.0); // Mobile: apenas margem direita
    }

    return GridView.builder(
      padding: padding, // Aplica o padding com base no dispositivo
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // Número de colunas
        crossAxisSpacing: screenWidth > tabletBreakpoint ? 60.0 : 8.0, // Espaçamento entre colunas
        mainAxisSpacing: screenWidth > tabletBreakpoint ? 30.0 : 8.0, // Espaçamento entre linhas
        childAspectRatio: (screenWidth / crossAxisCount) / fixedHeight, // Proporção ajustada
      ),
      itemCount: anuncios.length,
      itemBuilder: (context, index) {
        final anuncio = anuncios[index];
        return Card(
          child: Container(
            height: fixedHeight, // Altura fixa
            padding: EdgeInsets.all(screenWidth > tabletBreakpoint ? 15.0 : 8.0), // Padding menor no mobile
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
                      fontSize: screenWidth > tabletBreakpoint ? 40 : 24, // Fonte menor no mobile
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
                      fontSize: screenWidth > tabletBreakpoint ? 50 : 30, // Fonte menor no mobile
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
                            fontSize: screenWidth > tabletBreakpoint ? 12 : 10, // Fonte menor no mobile
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
                                    size: screenWidth > tabletBreakpoint ? 12 : 10, // Ícone menor no mobile
                                    color: Colors.grey[600],
                                  ),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                                TextSpan(
                                  text: ' Distância: ',
                                  style: TextStyle(
                                    fontSize: screenWidth > tabletBreakpoint ? 12 : 10, // Fonte menor no mobile
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextSpan(
                                  text: _distanciaText(anuncio),
                                  style: TextStyle(
                                    fontSize: screenWidth > tabletBreakpoint ? 12 : 10, // Fonte menor no mobile
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