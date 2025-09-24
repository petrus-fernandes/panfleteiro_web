import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImagemInterativa extends StatefulWidget {
  final String base64Image;

  const ImagemInterativa({super.key, required this.base64Image});

  @override
  State<ImagemInterativa> createState() => _ImagemInterativaState();
}

class _ImagemInterativaState extends State<ImagemInterativa> {
  Offset? _mousePos;
  bool _hovering = false;
  ui.Image? _decodedImage;

  @override
  void initState() {
    super.initState();
    _carregarImagem();
  }

  Future<void> _carregarImagem() async {
    final bytes = base64Decode(widget.base64Image);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() => _decodedImage = frame.image);
  }

  @override
  Widget build(BuildContext context) {
    if (_decodedImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) =>
                  Dialog(
                    insetPadding: const EdgeInsets.all(20),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.memory(
                        base64Decode(widget.base64Image),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
            );
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onHover: (event) => setState(() => _mousePos = event.localPosition),
            onExit: (_) =>
                setState(() {
                  _hovering = false;
                  _mousePos = null;
                }),
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ImagemComLupaPainter(
                image: _decodedImage!,
                mousePos: _mousePos,
                hovering: _hovering,
                zoom: 2.0,
                radius: 80.0,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ImagemComLupaPainter extends CustomPainter {
  final ui.Image image;
  final Offset? mousePos;
  final bool hovering;
  final double zoom;
  final double radius;

  _ImagemComLupaPainter({
    required this.image,
    required this.mousePos,
    required this.hovering,
    this.zoom = 2.0,
    this.radius = 80.0,
  });

  @override
  void paint(Canvas canvas, Size size) {

    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      fit: BoxFit.contain,
    );

    if (hovering && mousePos != null) {
      final rect = Rect.fromCircle(center: mousePos!, radius: radius);

      canvas.save();
      canvas.clipPath(Path()..addOval(rect));

      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(
          -(mousePos!.dx * (zoom - 1)),
          -(mousePos!.dy * (zoom - 1)),
          size.width * zoom,
          size.height * zoom,
        ),
        image: image,
        fit: BoxFit.contain,
      );

      canvas.restore();

      canvas.drawCircle(
        mousePos!,
        radius,
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ImagemComLupaPainter oldDelegate) =>
      oldDelegate.mousePos != mousePos ||
          oldDelegate.hovering != hovering ||
          oldDelegate.zoom != zoom ||
          oldDelegate.radius != radius;
}
