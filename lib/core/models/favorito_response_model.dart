class FavoriteResponse {
  final List<Favorito> content;
  final PageInfo page;

  FavoriteResponse({
    required this.content,
    required this.page,
  });

  factory FavoriteResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteResponse(
      content: List<Favorito>.from(
        json['content'].map((x) => Favorito.fromJson(x)),
      ),
      page: PageInfo.fromJson(json['page']),
    );
  }
}

class AnuncioDto {
  final int id;
  final String titulo;

  AnuncioDto({
    required this.id,
    required this.titulo,
  });

  factory AnuncioDto.fromJson(Map<String, dynamic> json) {
    return AnuncioDto(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
  };
}

class Favorito {
  final int id;
  final String nombreUsuario;
  final AnuncioDto anuncio;
  final double? precio;
  final DateTime fechaFavorito;
  final String? imagen;

  Favorito({
    required this.id,
    required this.nombreUsuario,
    required this.anuncio,
    this.precio,
    required this.fechaFavorito,
    this.imagen,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      id: json['id'] as int,
      nombreUsuario: json['nombreUsuario'] as String,
      anuncio: AnuncioDto.fromJson(json['anuncio']),
      precio: json['precio'] != null ? (json['precio'] as num).toDouble() : null,
      fechaFavorito: DateTime.parse(json['fechaFavorito'] as String),
      imagen: json['imagen'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombreUsuario': nombreUsuario,
    'anuncio': anuncio.toJson(),
    'precio': precio,
    'fechaFavorito': fechaFavorito.toIso8601String(),
    'imagen': imagen,
  };
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
      size: json['size'] as int,
      number: json['number'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}