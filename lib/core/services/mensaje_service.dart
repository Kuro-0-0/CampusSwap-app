import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/mensaje_interface.dart';
import 'package:campusswap_app/core/models/mensaje_response_model.dart';
import 'package:campusswap_app/core/services/auth_service.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class MensajeService implements MensajeInterface {

   final String _baseUrl = '${TokenStorage.baseUrl}/api/v1/mensajes';
  @override
  Future<MensajeResponse> obtenerMensajes(int idAnuncio, {int page = 0, int size = 20}) async {

   

  final token = await TokenStorage().getToken();
    final http.Response response;

    try {
      response = await http.get(
        Uri.parse('$_baseUrl/$idAnuncio?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const AuthException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw const AuthException('Error de conexión inesperado.');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return MensajeResponse.fromJson(body);
    } else if (response.statusCode == 401) {
      throw const AuthException('No autorizado. Vuelve a iniciar sesión.');
    } else if (response.statusCode == 403) {
      throw const AuthException('No tienes permiso para ver estos mensajes.');
    } else if (response.statusCode == 404) {
      throw const AuthException('Anuncio no encontrado.');
    } else {
      throw AuthException('Error del servidor (${response.statusCode}). Intenta más tarde.');
    }
  }

  
}