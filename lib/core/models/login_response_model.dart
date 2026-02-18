class LoginResponse {
  final String accessToken;
  final String email;

  LoginResponse({
    required this.email,
    required this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      email: json['email'] as String,
    );
  }
}