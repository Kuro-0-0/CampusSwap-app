class MensajeResponse {
  final List<Mensaje> content;
  final PaginationInfo page;

  MensajeResponse({
    required this.content,
    required this.page,
  });

  factory MensajeResponse.fromJson(Map<String, dynamic> json) {
    return MensajeResponse(
      content: List<Mensaje>.from(
        (json['content'] as List).map((item) => Mensaje.fromJson(item)),
      ),
      page: PaginationInfo.fromJson(json['page']),
    );
  }
}

class Mensaje {
  final String idEmisor;
  final String nombreEmisor;
  final String fotoEmisor;
  final String mensaje;
  final String fechaMensaje;

  Mensaje({
    required this.idEmisor,
    required this.nombreEmisor,
    required this.fotoEmisor,
    required this.mensaje,
    required this.fechaMensaje,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      idEmisor: json['idEmisor'] as String,
      nombreEmisor: json['nombreEmisor'] as String,
      fotoEmisor: json['fotoEmisor'] as String,
      mensaje: json['mensaje'] as String,
      fechaMensaje: json['fechaMensaje'] as String,
    );
  }
}

class PaginationInfo {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  PaginationInfo({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      size: json['size'] as int,
      number: json['number'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
