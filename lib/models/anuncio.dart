import 'package:intl/intl.dart';

import 'market.dart';

class Anuncio {
  final String name;
  final double price;
  final DateTime? expirationDate;
  final double? distance;
  final String? link;
  final bool active;
  final List<Market> markets;
  final double? latitude;
  final double? longitude;
  final String? marketName;
  final String? marketAddress;

  Anuncio({
    required this.name,
    required this.price,
    required this.expirationDate,
    required this.distance,
    required this.link,
    required this.active,
    required this.markets,
    required this.latitude,
    required this.longitude,
    required this.marketName,
    required this.marketAddress,
  });

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(
      name: json['productName'],
      price: json['price']?.toDouble(),
      expirationDate: json['expirationDate'] != null ? _parseDate(json['expirationDate']) : null,
      distance: json['markets']?.first['distance']?.toDouble(),
      link: json['url'],
      active: json['active'],
      markets: json['markets'] != null ? (json['markets'] as List).map((m) => Market.fromJson(m)).toList() : [],
      latitude: json['markets']?.first['location']?['latitude'].toDouble(),
      longitude: json['markets']?.first['location']?['longitude'].toDouble(),
      marketName: json['markets']?.first['name'],
      marketAddress: json['markets']?.first['location']?['address'],
    );
  }

  static DateTime _parseDate(String dateString) {
    final parts = dateString.split('-');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } else {
      throw FormatException('Formato de data inválido: $dateString');
    }
  }

  String distanciaText() {
    if (distance == null) {
      return '';
    }

    if (distance! < 1) {
      String? distanceBasicFormat = distance?.toStringAsFixed(3);
      double distanceBasicFormatDouble = double.parse(distanceBasicFormat!);
      return '${distanceBasicFormatDouble * 1000} m';
    }
    return '${_roundMetricScale(distance)} km';
  }

  static String _roundMetricScale(distance) {
    return NumberFormat('#,#0.0', 'pt-BR').format(distance);
  }
}