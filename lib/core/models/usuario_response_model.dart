class UsuarioResponse {
  final String id;
  final String nombre;
  final String email;
  final double? reputacionMedia;
  final String imageUrl;
  final DateTime fechaRegistro;
  final List<String> roles;
  final bool bloqueado;

  UsuarioResponse({
    required this.id,
    required this.nombre,
    required this.email,
    required this.reputacionMedia,
    required this.imageUrl,
    required this.fechaRegistro,
    required this.roles,
    required this.bloqueado,
  });

  factory UsuarioResponse.fromJson(Map<String, dynamic> json) {
    return UsuarioResponse(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      reputacionMedia: json['reputacionMedia'] == null ? null : (json['reputacionMedia'] as num).toDouble(),
      imageUrl: json['imageUrl'] == null ? '' : json['imageUrl'] as String,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      roles: List<String>.from(json['roles']),
      bloqueado: json['bloqueado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'reputacionMedia': reputacionMedia,
      'imageUrl': imageUrl,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'roles': roles,
      'bloqueado': bloqueado,
    };
  }
}