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

class Favorito {
  final String nombreUsuario;
  final String tituloAnuncio;
  final double? precio; // Nullable para intercambios o sin precio
  final DateTime fechaFavorito;
  final String? imagen; // Imagen del anuncio

  Favorito({
    required this.nombreUsuario,
    required this.tituloAnuncio,
    this.precio,
    required this.fechaFavorito,
    this.imagen,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      nombreUsuario: json['nombreUsuario'] as String,
      tituloAnuncio: json['tituloAnuncio'] as String,
      // Manejo seguro de nulos y conversión a double
      precio: json['precio'] != null ? (json['precio'] as num).toDouble() : null,
      fechaFavorito: DateTime.parse(json['fechaFavorito'] as String),
      imagen: json['imagen'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombreUsuario': nombreUsuario,
    'tituloAnuncio': tituloAnuncio,
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