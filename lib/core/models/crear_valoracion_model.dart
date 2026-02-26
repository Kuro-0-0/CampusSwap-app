class CrearValoracionModel {
  final double puntuacion;
  final String comentario;
  final String nombreEvaluador;
  final String nombreEvaluado;
  final String tituloAnuncio;
  final String fecha;

  CrearValoracionModel({
    required this.puntuacion,
    required this.comentario,
    required this.nombreEvaluador,
    required this.nombreEvaluado,
    required this.tituloAnuncio,
    required this.fecha,
  });

  factory CrearValoracionModel.fromJson(Map<String, dynamic> json) {
    return CrearValoracionModel(
      puntuacion: (json['puntuacion'] as num).toDouble(),
      comentario: json['comentario'] as String,
      nombreEvaluador: json['nombreEvaluador'] as String,
      nombreEvaluado: json['nombreEvaluado'] as String,
      tituloAnuncio: json['tituloAnuncio'] as String,
      fecha: json['fecha'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puntuacion': puntuacion,
      'comentario': comentario,
      'nombreEvaluador': nombreEvaluador,
      'nombreEvaluado': nombreEvaluado,
      'tituloAnuncio': tituloAnuncio,
      'fecha': fecha,
    };
  }
}
