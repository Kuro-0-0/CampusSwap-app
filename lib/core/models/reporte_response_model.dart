class ReporteResponseModel {
  final List<Reporte> content;
  final PageInfo page;

  ReporteResponseModel({required this.content, required this.page});

  factory ReporteResponseModel.fromJson(Map<String, dynamic> json) {
    return ReporteResponseModel(
      content: json['content'] != null
          ? List<Reporte>.from(
              (json['content'] as List).map((item) => Reporte.fromJson(item)),
            )
          : [],
      page: json['page'] != null
          ? PageInfo.fromJson(json['page'])
          : PageInfo(size: 0, number: 0, totalElements: 0, totalPages: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((item) => item.toJson()).toList(),
      'page': page.toJson(),
    };
  }
}

class AnuncioReporte {
  final int id;
  final String titulo;
  final String? imagen;
  final String autor;

  AnuncioReporte({
    required this.id,
    required this.titulo,
    this.imagen,
    required this.autor,
  });

  factory AnuncioReporte.fromJson(Map<String, dynamic> json) {
    return AnuncioReporte(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? 'Sin título',
      imagen: json['imagen'],
      autor: json['autor'] ?? 'Usuario Desconocido',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'imagen': imagen,
      'autor': autor,
    };
  }
}

class Reporte {
  final int id;
  final String motivo;
  final AnuncioReporte anuncio;
  final int cantidad;

  Reporte({
    required this.id,
    required this.motivo,
    required this.anuncio,
    required this.cantidad,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      id: json['id'] ?? 0,
      motivo: json['motivo'] ?? 'Sin especificar',
      anuncio: json['anuncio'] != null
          ? AnuncioReporte.fromJson(json['anuncio'])
          : AnuncioReporte(
              id: 0,
              titulo: 'Sin título',
              imagen: null,
              autor: 'Usuario Desconocido',
            ),
      cantidad: json['cantidad'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motivo': motivo,
      'anuncio': anuncio.toJson(),
      'cantidad': cantidad,
    };
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
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'number': number,
      'totalElements': totalElements,
      'totalPages': totalPages,
    };
  }
}
