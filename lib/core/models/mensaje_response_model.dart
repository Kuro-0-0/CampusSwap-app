import 'package:campusswap_app/core/models/anuncio_response_model.dart';

class MensajeResponse {
  final List<Conversacion> content;
  final Pagina page;

  MensajeResponse({required this.content, required this.page});

  factory MensajeResponse.fromJson(Map<String, dynamic> json) {
    return MensajeResponse(
      content: (json['content'] as List)
          .map((item) => Conversacion.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: Pagina.fromJson(json['page'] as Map<String, dynamic>),
    );
  }
}

class Conversacion {
  final AnuncioResumen anuncio;
  final List<Participante> participantes;
  final Mensaje ultimoMensaje;

  Conversacion({
    required this.anuncio,
    required this.participantes,
    required this.ultimoMensaje,
  });

  Participante get otroParticipante => participantes.firstWhere((p) => !p.yo);

  Participante get usuarioLogueado => participantes.firstWhere((p) => p.yo);

  bool get ultimoMensajeEsMio => ultimoMensaje.emisorId == usuarioLogueado.id;

  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      anuncio: AnuncioResumen.fromJson(json['anuncio'] as Map<String, dynamic>),
      participantes: (json['participantes'] as List)
          .map((p) => Participante.fromJson(p as Map<String, dynamic>))
          .toList(),
      ultimoMensaje: Mensaje.fromJson(
        json['ultimoMensaje'] as Map<String, dynamic>,
      ),
    );
  }
}

class AnuncioResumen {
  final int id;
  final String titulo;
  final String imagen;
  final double precio;

  AnuncioResumen({
    required this.id,
    required this.titulo,
    required this.imagen,
    required this.precio,
  });

  factory AnuncioResumen.fromJson(Map<String, dynamic> json) {
    return AnuncioResumen(
      id: json['id'] as int,
      titulo: json['titulo'] ?? 'Sin título',
      imagen: json['imagen'] ?? '',
      precio: json['precio'] != null ? (json['precio'] as num).toDouble() : 0.0,
    );
  }

  Anuncio toAnuncio() {
    return Anuncio(
      id: id,
      titulo: titulo,
      imagen: imagen,
      precio: precio,
      descripcion: '',
      categoria: '',
      tipoOperacion: '',
      estado: '',
      condicion: '',
      usuarioId: '',
    );
  }
}

class Participante {
  final String id;
  final String nombre;
  final bool yo;

  Participante({required this.id, required this.nombre, required this.yo});

  factory Participante.fromJson(Map<String, dynamic> json) {
    return Participante(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      yo: json['yo'] as bool,
    );
  }
}

class Mensaje {
  final int id;
  final String contenido;
  final DateTime fechaEnvio;
  final int anuncioId;
  final String emisorId;
  final String receptorId;

  Mensaje({
    required this.id,
    required this.contenido,
    required this.fechaEnvio,
    required this.anuncioId,
    required this.emisorId,
    required this.receptorId,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] as int,
      contenido: json['contenido'] as String,
      fechaEnvio: DateTime.parse(json['fechaEnvio'] as String),
      anuncioId: json['anuncioId'] as int,
      emisorId: json['emisorId'] as String,
      receptorId: json['receptorId'] as String,
    );
  }
}

class Pagina {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  Pagina({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory Pagina.fromJson(Map<String, dynamic> json) {
    return Pagina(
      size: json['size'] as int,
      number: json['number'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
