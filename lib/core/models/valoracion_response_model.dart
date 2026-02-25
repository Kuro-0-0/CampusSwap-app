class ValoracionResponse {
  final int id;
  final double puntuacion;
  final String comentario;
  final String fechaCreacion;
  final int idAnuncio;
  final int idValorador;

  ValoracionResponse({
    required this.id,
    required this.puntuacion,
    required this.comentario,
    required this.fechaCreacion,
    required this.idAnuncio,
    required this.idValorador,
  });

  factory ValoracionResponse.fromJson(Map<String, dynamic> json) {
    return ValoracionResponse(
      id: json['id'] ?? 0,
      puntuacion: (json['puntuacion'] ?? 0.0).toDouble(),
      comentario: json['comentario'] ?? '',
      fechaCreacion: json['fechaCreacion'] ?? '',
      idAnuncio: json['idAnuncio'] ?? 0,
      idValorador: json['idValorador'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'puntuacion': puntuacion,
    'comentario': comentario,
    'fechaCreacion': fechaCreacion,
    'idAnuncio': idAnuncio,
    'idValorador': idValorador,
  };
}
