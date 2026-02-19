import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/anuncio_interface.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class AnuncioException implements Exception {
  final String message;
  const AnuncioException(this.message);

  @override
  String toString() => message;
}

class AnuncioService implements IAnuncioResponse {
  final String _baseUrl = "http://10.0.2.2:8080/api/v1/catalogo";

  @override
  Future<AnuncioResponseModel> obtenerCatalogo({
    int page = 0,
    int size = 10,
    String sort = 'fechaPublicacion',
    String direction = 'DESC',
    String? q,
    int? categoriaId,
    double? minPrecio,
    double? maxPrecio,
    String? tipoOperacion,
    String? estado,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'size': size.toString(),
      'sort': '$sort,$direction',
    };

    if (q != null && q.isNotEmpty) {
      queryParams['q'] = q;
    }
    if (categoriaId != null) {
      queryParams['categoriaId'] = categoriaId.toString();
    }
    if (minPrecio != null) {
      queryParams['minPrecio'] = minPrecio.toString();
    }
    if (maxPrecio != null) {
      queryParams['maxPrecio'] = maxPrecio.toString();
    }
    if (tipoOperacion != null && tipoOperacion.isNotEmpty) {
      queryParams['tipoOperacion'] = tipoOperacion;
    }
    if (estado != null && estado.isNotEmpty) {
      queryParams['estado'] = estado;
    }

    final Uri uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    final http.Response response;

    try {
      response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${TokenStorage().getToken()}",
        },
      );
    } on SocketException {
      throw const AnuncioException(
          "No se pudo conectar al servidor. Verifica tu conexión.");
    } catch (e) {
      throw const AnuncioException("Error de conexión inesperado.");
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return AnuncioResponseModel.fromJson(body);
    } else if (response.statusCode == 400) {
      throw const AnuncioException("Parámetros de búsqueda inválidos.");
    } else if (response.statusCode == 401) {
      throw const AnuncioException("No autorizado. Por favor, inicia sesión.");
    } else if (response.statusCode == 403) {
      throw const AnuncioException("Acceso prohibido. No tienes permisos.");
    } else if (response.statusCode == 404) {
      throw const AnuncioException("Recurso no encontrado.");
    } else {
      throw AnuncioException(
        "Error del servidor (${response.statusCode}). Intenta más tarde.");
    }
  }
}
