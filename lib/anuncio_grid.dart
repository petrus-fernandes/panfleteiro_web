import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'anuncio.dart';

class AnuncioGrid extends StatelessWidget {
  final List<Anuncio> anuncios;

  AnuncioGrid({required this.anuncios});

  @override
  Widget build(BuildContext context) {
    // Obtém a largura da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final formatter = NumberFormat.currency(locale: "pt-BR", symbol: "R\$ ", decimalDigits: 2);

    // Define o número de colunas com base na largura da tela
    int crossAxisCount;
    if (screenWidth > 1350) {
      crossAxisCount = 3; // Telas grandes (monitores)
    } else if (screenWidth > 800) {
      crossAxisCount = 2; // Telas médias (tablets)
    } else {
      crossAxisCount = 1; // Telas pequenas (mobile)
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // Número de colunas
        crossAxisSpacing: 8.0, // Espaçamento entre colunas
        mainAxisSpacing: 8.0, // Espaçamento entre linhas
        childAspectRatio: 2.5, // Proporção de cada item (largura/altura)
      ),
      itemCount: anuncios.length,
      itemBuilder: (context, index) {
        final anuncio = anuncios[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anuncio.nome,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            formatter.format(anuncio.preco),
                            style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.red
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: 8,
                        right: 8,
                        child: Row(
                          children: [
                            if (anuncio.dataValidade != null)
                            Text(
                              'Validade: ${anuncio.dataValidade != null ? DateFormat('dd/MM/yyyy').format(anuncio.dataValidade!) : "Não informada"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                ),
                            ),
                            if (anuncio.distancia != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Distância: ${anuncio.distancia != null ? '${anuncio.distancia} km' : "Não informada"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  ),
                              ),
                            ),
                          ],
                        )
                    )
                ])

              ),
            ],
          ),
        );
      },
    );
  }
}
