import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImagemBase64 extends StatelessWidget {
  final String base64Image;

  const ImagemBase64({super.key, required this.base64Image});

  @override
  Widget build(BuildContext context) {
    try {
      // Se tiver prefixo tipo "data:image/jpeg;base64,..."
      final String base64Data = base64Image.contains(',')
          ? base64Image.split(',').last
          : base64Image;

      Uint8List bytes = base64Decode(base64Data);
      return Image.memory(bytes, fit: BoxFit.contain);
    } catch (e) {
      return const Center(child: Text('Erro ao carregar imagem'));
    }
  }
}
