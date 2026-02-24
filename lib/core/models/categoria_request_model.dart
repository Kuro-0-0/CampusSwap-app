class CategoriaRequestModel {
  final String nombre;
  final String descripcion;

  CategoriaRequestModel({
    required this.nombre,
    required this.descripcion,
  });

  factory CategoriaRequestModel.fromJson(Map<String, dynamic> json) {
    return CategoriaRequestModel(
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
