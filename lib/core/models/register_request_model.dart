class RegisterRequest {
  final String nombre;
  final String username;
  final String email;
  final String password;
  final String repeatPassword;

  RegisterRequest({
    required this.nombre,
    required this.username,
    required this.email,
    required this.password,
    required this.repeatPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'username': username,
      'email': email,
      'password': password,
      'repeatPassword': repeatPassword,
    };
  }
}
