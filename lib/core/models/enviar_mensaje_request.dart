class EnviarMensajeRequest {
  final String contenido;
  final int anuncioId;
  final String receptorId;

  EnviarMensajeRequest({
    required this.contenido,
    required this.anuncioId,
    required this.receptorId,
  });

  Map<String, dynamic> toJson() => {
    'contenido': contenido,
    'anuncioId': anuncioId,
    'receptorId': receptorId,
  };
}
