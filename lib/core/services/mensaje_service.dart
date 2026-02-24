import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/mensajes_interface.dart';
import 'package:campusswap_app/core/models/mensaje_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class MensajeException implements Exception {
  final String message;
  const MensajeException(this.message);

  @override
  String toString() => message;
}

class MensajeService implements MensajesInterface {
  final String _baseUrl = "${TokenStorage.baseUrl}/api/v1/mensajes"; 

  @override
  Future<MensajeResponse> getChats({int page = 0, int size = 20}) async {
    final Uri uri = Uri.parse("$_baseUrl/chats?page=$page&size=$size");
    final http.Response response;

    try {
      final token = await TokenStorage().getToken();

      response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    } on SocketException {
      throw const MensajeException(
          "No se pudo conectar al servidor. Verifica tu conexión.");
    } catch (e) {
      throw const MensajeException("Error de conexión inesperado.");
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return MensajeResponse.fromJson(body);
    } else if (response.statusCode == 401) {
      TokenStorage.triggerLogout();
      throw const MensajeException(
          "No autorizado. Por favor, inicia sesión.");
    } else if (response.statusCode == 403) {
      throw const MensajeException(
          "Acceso prohibido. No tienes permisos.");
    } else if (response.statusCode == 404) {
      throw const MensajeException("Recurso no encontrado.");
    } else {
      throw MensajeException(
          "Error del servidor (${response.statusCode}). Intenta más tarde.");
    }
  }
}
