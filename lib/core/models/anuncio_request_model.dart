class AnuncioRequestModel {
  final String titulo;
  final String descripcion;
  final double? precio;
  final String tipoOperacion;
  final String condicion;
  final int categoriaId;

  AnuncioRequestModel({
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.tipoOperacion,
    required this.condicion,
    required this.categoriaId,
  });

  factory AnuncioRequestModel.fromJson(Map<String, dynamic> json) {
    return AnuncioRequestModel(
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      precio: (json['precio'] as num).toDouble(),
      tipoOperacion: json['tipoOperacion'] as String,
      condicion: json['condicion'] as String,
      categoriaId: json['categoriaId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'tipoOperacion': tipoOperacion,
      'condicion': condicion,
      'categoriaId': categoriaId,
    };
  }
}