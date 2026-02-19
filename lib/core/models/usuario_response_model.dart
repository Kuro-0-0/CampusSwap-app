class UsuarioResponse {
  final String id;
  final String nombre;
  final String email;
  final double? reputacionMedia;
  final DateTime fechaRegistro;
  final List<String> roles;

  UsuarioResponse({
    required this.id,
    required this.nombre,
    required this.email,
    required this.reputacionMedia,
    required this.fechaRegistro,
    required this.roles,
  });

  // Factory constructor to create a User from JSON
  factory UsuarioResponse.fromJson(Map<String, dynamic> json) {
    return UsuarioResponse(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
        reputacionMedia: json['reputacionMedia'] == null ? null : (json['reputacionMedia'] as num).toDouble(),
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      roles: List<String>.from(json['roles']),
    );
  }

  // Method to convert User instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'reputacionMedia': reputacionMedia,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'roles': roles,
    };
  }
}