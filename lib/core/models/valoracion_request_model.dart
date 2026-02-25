class ValoracionRequest {
  final double puntuacion;
  final String comentario;
  final int idAnuncio;

  ValoracionRequest({
    required this.puntuacion,
    required this.comentario,
    required this.idAnuncio,
  });

  Map<String, dynamic> toJson() => {
    'puntuacion': puntuacion,
    'comentario': comentario,
    'idAnuncio': idAnuncio,
  };
}
