class Anuncio {
  final String nome;
  final double preco;
  final DateTime? dataValidade;
  final double? distancia;
  final String link;

  Anuncio({
    required this.nome,
    required this.preco,
    required this.dataValidade,
    required this.distancia,
    required this.link,
  });

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(
      nome: json['productName'],
      preco: json['price'].toDouble(),
      dataValidade: json['expirationDate'] != null ? _parseDate(json['expirationDate']) : null,
      distancia: json['distance']?.toDouble(),
      link: json['url'],
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
}