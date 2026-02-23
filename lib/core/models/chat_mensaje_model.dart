

class ChatMensajeResponse {
  final String idEmisor;
  final String nombreEmisor;
  final String? fotoEmisor;
  final String mensaje;
  final String fechaMensaje;

  ChatMensajeResponse({
    required this.idEmisor,
    required this.nombreEmisor,
    this.fotoEmisor,
    required this.mensaje,
    required this.fechaMensaje,
  });

  factory ChatMensajeResponse.fromJson(Map<String, dynamic> json) {
    return ChatMensajeResponse(
      idEmisor: json['idEmisor'] as String,
      nombreEmisor: json['nombreEmisor'] as String,
      fotoEmisor: json['fotoEmisor'] as String?,
      mensaje: json['mensaje'] as String,
      fechaMensaje: json['fechaMensaje'] as String,
    );
  }
}
