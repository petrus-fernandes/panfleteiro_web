class Validacao {
  final int id;
  final String imagemBase64;
  final String response;

  Validacao({required this.id, required this.imagemBase64, required this.response});

  factory Validacao.fromJson(Map<String, dynamic> json) {
    return Validacao(
        id: json['id'],
        imagemBase64: json['imageBase64'],
        response: json['response']
    );
  }
}
