import 'package:http/http.dart' as http;
import 'dart:convert';
import 'anuncio.dart';

class AnuncioService {
  final String baseUrl = "https://mercadao.co:8443";

  Future<List<Anuncio>> fetchAnunciosPorNome(String productName, int page, int size) async {
    final response = await http.get(Uri.parse('$baseUrl/v1/anuncios/buscaPorNome?productName=$productName&page=$page&size=$size'));

    if (response.statusCode == 200) {

      List<dynamic> body = jsonDecode(response.body)['content'];
      return body.map((dynamic item) => Anuncio.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load anuncios');
    }
  }

  fetchAnunciosPorLocalizacao(double latitude, double longitude, String searchTerm, int page, int size) async {
    final response = await http.get(Uri.parse('$baseUrl/v1/anuncios/buscaPorDistanciaENome?longitude=$longitude&latitude=$latitude&rangeInKm=15&page=$page&size=$size&productName=$searchTerm'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['content'];
      return body.map((dynamic item) => Anuncio.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load anuncios');
    }
  }
}
