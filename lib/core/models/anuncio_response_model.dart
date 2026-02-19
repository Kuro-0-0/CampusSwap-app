class AnuncioResponse {
  final List<Anuncio> content;
  final PageInfo page;

  AnuncioResponse({required this.content, required this.page});

  factory AnuncioResponse.fromJson(Map<String, dynamic> json) {
    return AnuncioResponse(
      content: List<Anuncio>.from(
        json['content'].map((x) => Anuncio.fromJson(x)),
      ),
      page: PageInfo.fromJson(json['page']),
    );
  }
}

class Anuncio {
  final int id;
  final String titulo;
  final String descripcion;
  final double? precio;
  final String categoria;
  final String imagen;
  final String tipoOperacion;
  final String estado;
  final String condicion;
  final String usuarioId;

  Anuncio({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.precio,
    required this.categoria,
    required this.imagen,
    required this.tipoOperacion,
    required this.estado,
    required this.condicion,
    required this.usuarioId,
  });

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      precio: json['precio'] != null ? (json['precio'] as num).toDouble() : null,
      categoria: json['categoria'],
      imagen: json['imagen'],
      tipoOperacion: json['tipoOperacion'],
      estado: json['estado'],
      condicion: json['condicion'],
      usuarioId: json['usuarioId'],
    );
  }
}

class PageInfo {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  PageInfo({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      size: json['size'],
      number: json['number'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
    );
  }
}