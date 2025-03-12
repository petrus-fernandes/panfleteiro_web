import 'package:http/http.dart' as http;
import 'dart:convert';
import 'anuncio.dart';

class AnuncioService {
  final String baseUrl = "http://mercadao.co";

  Future<List<Anuncio>> fetchAnunciosPorNome(String productName, int page, int size) async {
    final response = await http.get(Uri.parse('$baseUrl/v1/anuncios/buscaPorNome?productName=$productName&page=$page&size=$size'));
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {

      List<dynamic> body = jsonDecode(response.body)['content'];
      return body.map((dynamic item) => Anuncio.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load anuncios');
    }
  }
}