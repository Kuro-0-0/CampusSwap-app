import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/models/valoracion_request_model.dart';
import 'package:campusswap_app/core/models/valoracion_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class ValoracionException implements Exception {
  final String message;
  const ValoracionException(this.message);

  @override
  String toString() => message;
}

class ValoracionService {
  final String _baseUrl = "${TokenStorage.baseUrl}/api/v1/valoraciones";

  Future<ValoracionResponse> crearValoracion(ValoracionRequest request) async {
    final token = await TokenStorage().getToken();
    
    if (token == null) {
      throw const ValoracionException("No hay token de autenticación");
    }

    final http.Response response;

    try {
      response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(request.toJson()),
      );
    } on SocketException {
      throw const ValoracionException(
        "No se pudo conectar al servidor. Verifica tu conexión.",
      );
    } catch (e) {
      throw const ValoracionException("Error de conexión inesperado.");
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return ValoracionResponse.fromJson(body);
    } else if (response.statusCode == 401) {
      throw const ValoracionException("Tu sesión ha expirado. Por favor, inicia sesión nuevamente.");
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final message = body['message'] ?? 'Error al crear la valoración';
      throw ValoracionException(message);
    } else if (response.statusCode == 409) {
      throw const ValoracionException("Ya has valorado este anuncio.");
    } else {
      throw const ValoracionException("Error al crear la valoración. Intenta más tarde.");
    }
  }
}
