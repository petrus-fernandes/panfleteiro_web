import 'package:intl/intl.dart';

class Market {
  final int? id;
  final String? name;
  final Location? location;
  final String? externalCode;
  final List<int>? marketsId;
  final bool? headQuarters;
  final double? distance;

  Market({
    this.id,
    this.name,
    this.location,
    this.externalCode,
    this.marketsId,
    this.headQuarters,
    this.distance,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'],
      name: json['name'],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      externalCode: json['externalCode'],
      marketsId: json['marketsId'] != null ? List<int>.from(json['marketsId']) : null,
      headQuarters: json['headQuarters'],
      distance: json['distance']?.toDouble(),
    );
  }
}

class Location {
  final double? latitude;
  final double? longitude;
  final String? address;

  Location({
    this.latitude,
    this.longitude,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
    );
  }
}