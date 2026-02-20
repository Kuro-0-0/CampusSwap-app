import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/anuncio_interface.dart';
import 'package:campusswap_app/core/models/anuncio_request_model.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
      var token = await TokenStorage().getToken();

      response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
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

  @override
  Future<void> pauseAnuncio(int anuncioId) async {
    await _toggleAnuncioState(anuncioId);
  }

  @override
  Future<void> enableAnuncio(int anuncioId) async {
    await _toggleAnuncioState(anuncioId);
  }

  Future<void> _toggleAnuncioState(int anuncioId) async {
    try {
      final token = await TokenStorage().getToken();
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8080/api/v1/anuncios/$anuncioId/alternar-estado'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const AnuncioException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const AnuncioException('No tienes permiso para realizar esta acción.');
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Anuncio no encontrado.');
      } else {
        throw AnuncioException('Error al alternar estado del anuncio (${response.statusCode})');
      }
    } on SocketException {
      throw const AnuncioException('No se pudo conectar al servidor.');
    } catch (e) {
      throw AnuncioException('Error inesperado: $e');
    }
  }

  @override
  Future<void> deleteAnuncio(int anuncioId) async {
    try {
      final token = await TokenStorage().getToken();
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8080/api/v1/anuncios/$anuncioId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const AnuncioException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const AnuncioException('No tienes permiso para eliminar este anuncio.');
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Anuncio no encontrado.');
      } else {
        throw AnuncioException('Error al eliminar anuncio (${response.statusCode})');
      }
    } on SocketException {
      throw const AnuncioException('No se pudo conectar al servidor.');
    } catch (e) {
      throw AnuncioException('Error inesperado: $e');
    }
  }

  @override
  Future<Anuncio> crearAnuncio(AnuncioRequestModel requestModel) async {
    try {
      final token = await TokenStorage().getToken();
      final uri = Uri.parse('http://10.0.2.2:8080/api/v1/anuncios');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(http.MultipartFile.fromString(
        'nuevoAnuncio', 
        jsonEncode(requestModel.toJson()),
        contentType: MediaType('application', 'json'),
      ));

      if (requestModel.imagen.isNotEmpty && !requestModel.imagen.startsWith('http')) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          requestModel.imagen,
        ));
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Anuncio.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 400) {
        throw const AnuncioException('Datos del anuncio inválidos.');
      } else if (response.statusCode == 401) {
        throw const AnuncioException('No autorizado. Por favor, inicia sesión.');
      } else {
        throw AnuncioException('Error al crear anuncio (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw const AnuncioException('No se pudo conectar al servidor.');
    } catch (e) {
      throw AnuncioException('Error inesperado: $e');
    }
  }

  @override
  Future<Anuncio> editarAnuncio(int id, AnuncioRequestModel requestModel) async {
    try {
      final token = await TokenStorage().getToken();
      final uri = Uri.parse('http://10.0.2.2:8080/api/v1/anuncios/$id');
      
      var request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(http.MultipartFile.fromString(
        'anuncioModificado', 
        jsonEncode(requestModel.toJson()),
        contentType: MediaType('application', 'json'),
      ));

      if (requestModel.imagen.isNotEmpty && !requestModel.imagen.startsWith('http')) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          requestModel.imagen,
        ));
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return Anuncio.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 400) {
        throw const AnuncioException('Datos del anuncio inválidos.');
      } else if (response.statusCode == 403) {
        throw const AnuncioException('No tienes permiso para editar este anuncio.');
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Anuncio no encontrado.');
      } else {
        throw AnuncioException('Error al editar anuncio (${response.statusCode})');
      }
    } on SocketException {
      throw const AnuncioException('No se pudo conectar al servidor.');
    } catch (e) {
      throw AnuncioException('Error inesperado: $e');
    }
  }
}
