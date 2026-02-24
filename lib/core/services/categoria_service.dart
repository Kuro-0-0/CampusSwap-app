import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/categoria_interface.dart';
import 'package:campusswap_app/core/models/categoria_request_model.dart';
import 'package:campusswap_app/core/models/categoria_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class CategoriaException implements Exception {
  final String message;
  final String? code; // 'conflict', 'unauthorized', etc.

  const CategoriaException(this.message, {this.code});

  @override
  String toString() => message;
}

class CategoriaService implements ICategoriaResponse {
  final String _baseUrl = "${TokenStorage.baseUrl}/api/v1/categorias";
  final String _adminUrl = "${TokenStorage.baseUrl}/api/v1/admin/categorias";

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
        "No se pudo conectar al servidor. Verifica tu conexión.",
      );
    } catch (e) {
      throw const CategoriaException("Error de conexión inesperado.");
    }

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => CategoriaResponseModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      TokenStorage.triggerLogout();
      throw const CategoriaException(
        "No autorizado. Por favor, inicia sesión.",
      );
    } else if (response.statusCode == 403) {
      throw const CategoriaException("Acceso prohibido. No tienes permisos.");
    } else if (response.statusCode == 404) {
      throw const CategoriaException("Recurso no encontrado.");
    } else {
      throw CategoriaException(
        "Error del servidor (${response.statusCode}). Intenta más tarde.",
      );
    }
  }

  Future<CategoriaResponseModel> crearCategoria(
    CategoriaRequestModel categoria,
  ) async {
    final Uri uri = Uri.parse(_adminUrl);

    final http.Response response;

    try {
      var token = await TokenStorage().getToken();

      response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(categoria.toJson()),
      );
    } on SocketException {
      throw const CategoriaException(
        "No se pudo conectar al servidor. Verifica tu conexión.",
      );
    } catch (e) {
      throw const CategoriaException("Error de conexión inesperado.");
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return CategoriaResponseModel.fromJson(body);
    } else if (response.statusCode == 400) {
      throw const CategoriaException(
        "Solicitud inválida. Verifica que el nombre no exista.",
      );
    } else if (response.statusCode == 401) {
      TokenStorage.triggerLogout();
      throw const CategoriaException(
        "No autorizado. Por favor, inicia sesión.",
      );
    } else if (response.statusCode == 403) {
      throw const CategoriaException(
        "Acceso prohibido. No tienes permisos de administrador.",
      );
    } else {
      throw CategoriaException(
        "Error del servidor (${response.statusCode}). Intenta más tarde.",
      );
    }
  }

  Future<CategoriaResponseModel> actualizarCategoria(
    int categoryId,
    CategoriaRequestModel categoria,
  ) async {
    final Uri uri = Uri.parse('$_adminUrl/$categoryId');

    final http.Response response;

    try {
      var token = await TokenStorage().getToken();

      response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(categoria.toJson()),
      );
    } on SocketException {
      throw const CategoriaException(
        "No se pudo conectar al servidor. Verifica tu conexión.",
      );
    } catch (e) {
      throw const CategoriaException("Error de conexión inesperado.");
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return CategoriaResponseModel.fromJson(body);
    } else if (response.statusCode == 400) {
      throw const CategoriaException(
        "Solicitud inválida. Verifica los datos de la categoría.",
      );
    } else if (response.statusCode == 401) {
      TokenStorage.triggerLogout();
      throw const CategoriaException(
        "No autorizado. Por favor, inicia sesión.",
      );
    } else if (response.statusCode == 403) {
      throw const CategoriaException(
        "Acceso prohibido. No tienes permisos de administrador.",
      );
    } else if (response.statusCode == 404) {
      throw const CategoriaException("Categoría no encontrada.");
    } else {
      throw CategoriaException(
        "Error del servidor (${response.statusCode}). Intenta más tarde.",
      );
    }
  }

  Future<void> eliminarCategoria(int categoryId) async {
    final Uri uri = Uri.parse('$_adminUrl/$categoryId');

    final http.Response response;

    try {
      var token = await TokenStorage().getToken();

      response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
    } on SocketException {
      throw const CategoriaException(
        "No se pudo conectar al servidor. Verifica tu conexión.",
      );
    } catch (e) {
      throw const CategoriaException("Error de conexión inesperado.");
    }

    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const CategoriaException(
          "No autorizado. Por favor, inicia sesión.",
        );
      } else if (response.statusCode == 403) {
        throw const CategoriaException(
          "Acceso prohibido. No tienes permisos de administrador.",
        );
      } else if (response.statusCode == 404) {
        throw const CategoriaException("Categoría no encontrada.");
      } else if (response.statusCode == 409) {
        throw CategoriaException(
          "No se puede eliminar esta categoría porque está relacionada con anuncios existentes. Edita los anuncios para cambiar su categoría o elimina los anuncios primero.",
          code: 'conflict',
        );
      } else {
        throw CategoriaException(
          "Error del servidor (${response.statusCode}). Intenta más tarde.",
        );
      }
    }
  }
}
