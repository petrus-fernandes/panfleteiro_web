import 'package:intl/intl.dart';

class Anuncio {
  final String nome;
  final double preco;
  final DateTime? dataValidade;
  final double? distancia;
  final String link;
  final double? latitude;
  final double? longitude;
  final String? marketName;
  final String? marketAddress;

  Anuncio({
    required this.nome,
    required this.preco,
    required this.dataValidade,
    required this.distancia,
    required this.link,
    required this.latitude,
    required this.longitude,
    required this.marketName,
    required this.marketAddress,
  });

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(
      nome: json['productName'],
      preco: json['price']?.toDouble(),
      dataValidade: json['expirationDate'] != null ? _parseDate(json['expirationDate']) : null,
      distancia: json['distance']?.toDouble(),
      link: json['url'],
      latitude: json['market']?['location']?['latitude'].toDouble(),
      longitude: json['market']?['location']?['longitude']?.toDouble(),
      marketName: json['market']?['name'],
      marketAddress: json['market']?['location']?['address']
    );
  }

  static DateTime _parseDate(String dateString) {
    final parts = dateString.split('-'); // Divide a string em partes
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day); // Cria um objeto DateTime
    } else {
      throw FormatException('Formato de data inválido: $dateString');
    }
  }

  String distanciaText() {
    if (distancia == null) {
      return '';
    }

    if (distancia! < 1) {
      String? distanceBasicFormat = distancia?.toStringAsFixed(3);
      double distanceBasicFormatDouble = double.parse(distanceBasicFormat!);
      return '${distanceBasicFormatDouble * 1000} m';
    }
    return '${_roundMetricScale(distancia)} km';
  }

  static String _roundMetricScale(distance) {
    return NumberFormat('#,#0.0', 'pt-BR').format(distance);
  }
}