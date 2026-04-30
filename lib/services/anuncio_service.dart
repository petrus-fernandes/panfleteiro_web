import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/anuncio.dart';

class AnuncioService {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  Future<List<Anuncio>> fetchAnunciosPorNome(
    String productName,
    int page,
    int size,
  ) async {
    final uri = Uri.parse('$baseUrl/v1/anuncios').replace(
      queryParameters: {
        'productName': productName,
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['content'];
      return body.map((dynamic item) => Anuncio.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load anuncios');
    }
  }

  Future<List<Anuncio>> fetchAnunciosPorLocalizacao(
    double? latitude,
    double? longitude,
    String searchTerm,
    int page,
    int size,
    int distance, {
    String? cep,
  }) async {
    final queryParameters = {
      'longitude': longitude?.toString(),
      'latitude': latitude?.toString(),
      'rangeInKm': distance.toString(),
      'page': page.toString(),
      'size': size.toString(),
      'productName': searchTerm,
    };

    if (cep != null && cep.isNotEmpty) {
      queryParameters['cep'] = cep;
    }

    final uri = Uri.parse('$baseUrl/v1/anuncios')
        .replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['content'];
      return body.map((dynamic item) => Anuncio.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load anuncios');
    }
  }
}
