import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/categoria_interface.dart';
import 'package:campusswap_app/core/models/categoria_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class CategoriaException implements Exception {
  final String message;
  const CategoriaException(this.message);

  @override
  String toString() => message;
}

class CategoriaService implements ICategoriaResponse {
  final String _baseUrl = "${TokenStorage.baseUrl}/api/v1/categorias";

  @override
  Future<List<CategoriaResponseModel>> obtenerCategorias() async {
    final Uri uri = Uri.parse(_baseUrl);

    final http.Response response;

    try {
      var token = await TokenStorage().getToken();

      response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
    } on SocketException {
      throw const CategoriaException(
          "No se pudo conectar al servidor. Verifica tu conexión.");
    } catch (e) {
      throw const CategoriaException("Error de conexión inesperado.");
    }

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((json) => CategoriaResponseModel.fromJson(json))
          .toList();
    } else if (response.statusCode == 401) {
      throw const CategoriaException("No autorizado. Por favor, inicia sesión.");
    } else if (response.statusCode == 403) {
      throw const CategoriaException("Acceso prohibido. No tienes permisos.");
    } else if (response.statusCode == 404) {
      throw const CategoriaException("Recurso no encontrado.");
    } else {
      throw CategoriaException(
        "Error del servidor (${response.statusCode}). Intenta más tarde.");
    }
  }
}
