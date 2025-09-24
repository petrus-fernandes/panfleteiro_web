import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/anuncio.dart';
import '../theme/my_flutter_app_icons.dart';

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: !anuncio.active ? Colors.grey[300] : null, // Cor de fundo acinzentada para desativados
            child: Container(
              height: fixedHeight,
              padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: !anuncio.active ? null : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: !anuncio.active
                      ? [Colors.grey[400]!, Colors.grey[300]!] // Gradiente cinza para desativados
                      : [
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                  ],
                ),
                color: !anuncio.active ? Colors.grey[300] : null, // Cor de fundo adicional
              ),
              child: Opacity(
                opacity: !anuncio.active ? 0.6 : 1.0, // Reduz a opacidade para desativados
                child: Stack(
                  children: [
                    // Nome do produto
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05), // Fundo sutil
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          anuncio.name,
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 32,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.3,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Preço no canto inferior esquerdo
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Text(
                        formatter.format(anuncio.price),
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
                          if (anuncio.expirationDate != null)
                            _buildInfoChip(
                              context,
                              icon: Icons.calendar_today,
                              text: DateFormat('dd/MM/yy').format(anuncio.expirationDate!),
                              isMobile: isMobile,
                              color: Colors.red.shade100,
                              anuncio: anuncio
                            ),
                          if (anuncio.distance != null)
                            _buildInfoChip(
                              context,
                              icon: MyFlutterApp.marker,
                              text: anuncio.distanciaText(),
                              isMobile: isMobile,
                              color: null,
                              anuncio: anuncio
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        );
      },
    );
  }

  Widget _buildInfoChip(BuildContext context, {
    required IconData icon,
    required String text,
    required bool isMobile,
    Color? color,
    required Anuncio anuncio
  }) {
    final isDesativado = !anuncio.active;

    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDesativado
            ? Colors.grey[400]
            : color ?? Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isMobile ? 12 : 14,
            color: isDesativado
                ? Colors.grey[700]
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 11 : 13,
              color: isDesativado
                  ? Colors.grey[700]
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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

  Future<void> _openAnunciante() async {
    if (await canLaunch(anuncio.link ?? '')) {
      await launch(anuncio.link ?? '', forceSafariVC: false, forceWebView: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7, // 70% da altura da tela
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      anuncio.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(height: 10),

                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Preço em destaque
                          Row(
                            children: [
                              Text(
                                'Preço: ',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: "pt-BR",
                                  symbol: "R\$ ",
                                ).format(anuncio.price),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // Linha divisória
                          Divider(height: 1, thickness: 1),
                          SizedBox(height: 12),

                          // Demais informações
                          if (anuncio.expirationDate != null) ...[
                            _buildInfoRow(context, Icons.calendar_today,
                                'Válido até: ${DateFormat('dd/MM/yyyy').format(anuncio.expirationDate!)}'),
                            SizedBox(height: 8),
                          ],
                          if (anuncio.distance != null) ...[
                            _buildInfoRow(context, Icons.location_on,
                                'Distância: ${anuncio.distanciaText()}'),
                            SizedBox(height: 8),
                          ],
                          if (anuncio.marketName != null) ...[
                            _buildInfoRow(context, Icons.store,
                                'Mercado: ${anuncio.marketName}'),
                            SizedBox(height: 8),
                          ],
                          if (anuncio.marketAddress != null) ...[
                            _buildInfoRow(context, Icons.map,
                                'Endereço: ${anuncio.marketAddress}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9, // Proporção widescreen (16:9)
                        child: anuncio.markets[0].location?.latitude != null && anuncio.markets[0].location?.longitude != null
                            ? GestureDetector(
                          onTap: _openGoogleMaps,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calcula dimensões baseadas no espaço disponível
                              final width = constraints.maxWidth;
                              final height = constraints.maxHeight;

                              return Image.network(
                                'https://maps.googleapis.com/maps/api/staticmap?'
                                    'center=${anuncio.latitude},${anuncio.longitude}'
                                    '&zoom=16'
                                    '&size=${width.round()}x${height.round()}'
                                    '&scale=2'
                                    '&maptype=roadmap'
                                    '&markers=color:red%7C${anuncio.latitude},${anuncio.longitude}'
                                    '&key=${dotenv.env['GOOGLE_API_KEY']}',
                                fit: BoxFit.cover,
                                headers: {'Accept': 'image/*'},
                                loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorBuilder: (_, __, ___) => Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.red),
                                      Text('Falha ao carregar o mapa'),
                                    ],
                                  ),
                                ),
                              );
                            },
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
          SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _openAnunciante,
            style: FilledButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Colors.red.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_business_rounded),
                SizedBox(width: 8),
                Text('Abrir Anúncio'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
