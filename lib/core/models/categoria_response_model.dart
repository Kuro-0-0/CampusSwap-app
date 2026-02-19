class CategoriaResponseModel {
  final int id;
  final String nombre;

  CategoriaResponseModel({
    required this.id,
    required this.nombre,
  });

  factory CategoriaResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoriaResponseModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}