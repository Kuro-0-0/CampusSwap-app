class RegisterResponse {
  final String uuid;
  final String nombre;
  final String username;
  final String email;
  final String token;

  RegisterResponse({
    required this.uuid,
    required this.nombre,
    required this.username,
    required this.email,
    required this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      uuid: json['uuid'] ?? '',
      nombre: json['nombre'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
    );
  }

  
}