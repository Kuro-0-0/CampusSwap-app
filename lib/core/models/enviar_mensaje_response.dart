class EnviarMensajeResponse {
  final int id;
  final String contenido;
  final DateTime fechaEnvio;
  final int anuncioId;
  final String emisorId;
  final String receptorId;

  EnviarMensajeResponse({
    required this.id,
    required this.contenido,
    required this.fechaEnvio,
    required this.anuncioId,
    required this.emisorId,
    required this.receptorId,
  });

  factory EnviarMensajeResponse.fromJson(Map<String, dynamic> json) {
    return EnviarMensajeResponse(
      id: json['id'] as int,
      contenido: json['contenido'] as String,
      fechaEnvio: DateTime.parse(json['fechaEnvio'] as String),
      anuncioId: json['anuncioId'] as int,
      emisorId: json['emisorId'] as String,
      receptorId: json['receptorId'] as String,
    );
  }
}
