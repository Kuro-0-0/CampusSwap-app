class CategoriaResponseModel {
  final int id;
  final String nombre;
  final String descripcion;

  CategoriaResponseModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory CategoriaResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoriaResponseModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}