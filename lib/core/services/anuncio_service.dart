import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/anuncio_interface.dart';
import 'package:campusswap_app/core/models/anuncio_request_model.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/reporte_request_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AnuncioException implements Exception {
  final String message;
  const AnuncioException(this.message);

  @override
  String toString() => message;
}

class AnuncioService implements IAnuncioResponse {
  final String _catalogoUrl = "${TokenStorage.baseUrl}/api/v1/catalogo";
  final String _baseUrl = "${TokenStorage.baseUrl}/api/v1/anuncios";

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
    } else {
      queryParams['estado'] = 'ACTIVO';
    }

    final Uri uri = Uri.parse(
      _catalogoUrl,
    ).replace(queryParameters: queryParams);

    final http.Response response;

    try {
      var token = await TokenStorage().getToken();

      Map<String, String> headers = {"Content-Type": "application/json"};

      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      response = await http.get(uri, headers: headers);
    } on SocketException {
      throw const AnuncioException(
        "No se pudo conectar al servidor. Verifica tu conexión.",
      );
    } catch (e) {
      throw const AnuncioException("Error de conexión inesperado.");
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return AnuncioResponseModel.fromJson(body);
    } else if (response.statusCode == 400) {
      throw const AnuncioException("Parámetros de búsqueda inválidos.");
    } else if (response.statusCode == 401) {
      TokenStorage.triggerLogout();
      throw const AnuncioException("No autorizado. Por favor, inicia sesión.");
    } else if (response.statusCode == 403) {
      throw const AnuncioException("Acceso prohibido. No tienes permisos.");
    } else if (response.statusCode == 404) {
      throw const AnuncioException("Recurso no encontrado.");
    } else {
      throw AnuncioException(
        "Error del servidor (${response.statusCode}). Intenta más tarde.",
      );
    }
  }

  @override
  Future<Anuncio> getAnuncioById(int anuncioId) async {
    try {
      var token = await TokenStorage().getToken();
      
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };

      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/unique/$anuncioId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return Anuncio.fromJson(body);
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const AnuncioException(
          'No autorizado. Por favor, inicia sesión.',
        );
      } else if (response.statusCode == 403) {
        throw const AnuncioException(
          'No tienes permiso para acceder a este anuncio.',
        );
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Anuncio no encontrado.');
      } else {
        throw AnuncioException(
          'Error al obtener el anuncio (${response.statusCode})',
        );
      }
    } on SocketException {
      throw const AnuncioException('No se pudo conectar al servidor.');
    } catch (e) {
      throw AnuncioException('Error inesperado: $e');
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
      final response = await http
          .put(
            Uri.parse('$_baseUrl/$anuncioId/alternar-estado'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const AnuncioException(
          'No autorizado. Por favor, inicia sesión.',
        );
      } else if (response.statusCode == 403) {
        throw const AnuncioException(
          'No tienes permiso para realizar esta acción.',
        );
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Anuncio no encontrado.');
      } else {
        throw AnuncioException(
          'Error al alternar estado del anuncio (${response.statusCode})',
        );
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
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/$anuncioId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const AnuncioException(
          'No autorizado. Por favor, inicia sesión.',
        );
      } else if (response.statusCode == 403) {
        throw const AnuncioException(
          'No tienes permiso para eliminar este anuncio.',
        );
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Anuncio no encontrado.');
      } else {
        throw AnuncioException(
          'Error al eliminar anuncio (${response.statusCode})',
        );
      }
    } on SocketException {
      throw const AnuncioException('No se pudo conectar al servidor.');
    } catch (e) {
      throw AnuncioException('Error inesperado: $e');
    }
  }

  @override
  Future<void> crearAnuncio(
    AnuncioRequestModel anuncio,
    String rutaImagen,
  ) async {
    try {
      final token = await TokenStorage().getToken();
      final uri = Uri.parse(_baseUrl);

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        http.MultipartFile.fromString(
          'data',
          jsonEncode(anuncio.toJson()),
          contentType: MediaType('application', 'json'),
        ),
      );

      final mimeType = lookupMimeType(rutaImagen);

      if (mimeType == null) {
        return;
      }

      final subTypePart = mimeType.split('/')[1];

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          rutaImagen,
          contentType: MediaType('image', subTypePart),
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return;
      } else if (response.statusCode == 400) {
        throw const AnuncioException('Solicitud inválida, revise los campos');
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const AnuncioException(
          'No autorizado. Por favor, inicia sesión.',
        );
      } else if (response.statusCode == 403) {
        throw const AnuncioException('No tienes permiso para crear anuncios.');
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Entidad no encontrada.');
      } else {
        throw AnuncioException(
          'Error al crear el anuncio: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const AnuncioException('No se pudo conectar al servidor.');
    } catch (e) {
      throw AnuncioException('Error inesperado: $e');
    }
  }

  @override
  Future<void> editarAnuncio(
    int id,
    AnuncioRequestModel anuncio, [
    String? rutaImagen,
  ]) async {
    try {
      final token = await TokenStorage().getToken();
      final uri = Uri.parse('$_baseUrl/$id');

      var request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        http.MultipartFile.fromString(
          'data',
          jsonEncode(anuncio.toJson()),
          contentType: MediaType('application', 'json'),
        ),
      );

      if (rutaImagen != null && rutaImagen.isNotEmpty) {
        final mimeType = lookupMimeType(rutaImagen);

        if (mimeType != null) {
          final subTypePart = mimeType.split('/')[1];
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              rutaImagen,
              contentType: MediaType('image', subTypePart),
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('file', rutaImagen),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        throw const AnuncioException('Solicitud inválida, revise los campos');
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const AnuncioException(
          'No autorizado. Por favor, inicia sesión.',
        );
      } else if (response.statusCode == 403) {
        throw const AnuncioException('No tienes permiso para crear anuncios.');
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Entidad no encontrada.');
      } else {
        throw AnuncioException(
          'Error al crear el anuncio: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw AnuncioException('Error de conexión al editar el anuncio: $e');
    }
  }
  @override
  Future<void> eliminarAnuncioAdmin(int anuncioId) async {
    try {
      final token = await TokenStorage().getToken();
      final response = await http
          .delete(
            Uri.parse(
              '${TokenStorage.baseUrl}/api/v1/admin/anuncios/$anuncioId',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const AnuncioException(
          'No autorizado. Por favor, inicia sesión.',
        );
      } else if (response.statusCode == 403) {
        throw const AnuncioException(
          'No tienes permiso para eliminar este anuncio.',
        );
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Anuncio no encontrado.');
      } else {
        throw AnuncioException(
          'Error al eliminar anuncio (${response.statusCode})',
        );
      }
    } on SocketException {
      throw const AnuncioException('No se pudo conectar al servidor.');
    } catch (e) {
      throw AnuncioException('Error inesperado: $e');
    }
  }
  
  Future<void> reportarAnuncio(int anuncioId, String motivo) async {
    try {
      final token = await TokenStorage().getToken();
      final reporteRequest = ReporteRequestModel(motivo: motivo);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/$anuncioId/reportar'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(reporteRequest.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const AnuncioException(
          'No autorizado. Por favor, inicia sesión.',
        );
      } else if (response.statusCode == 403) {
        throw const AnuncioException(
          'No tienes permiso para reportar este anuncio.',
        );
      } else if (response.statusCode == 404) {
        throw const AnuncioException('Anuncio no encontrado.');
      } else if (response.statusCode == 400) {
        throw const AnuncioException('Datos de reporte inválidos.');
      } else if (response.statusCode == 409) {
        throw const AnuncioException('Ya has reportado este anuncio.');
      } else {
        throw AnuncioException(
          'Error al reportar anuncio (${response.statusCode})',
        );
      }
    } on SocketException {
      throw const AnuncioException('No se pudo conectar al servidor.');
    } catch (e) {
      throw AnuncioException('Error inesperado: $e');
    }
  }

  @override
  Future<void> comprarAnuncio(int anuncioId) async {
    try {
      final token = await TokenStorage().getToken();
      final response = await http
          .put(
            Uri.parse('$_baseUrl/$anuncioId/comprar'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const AnuncioException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 409) {
        throw AnuncioException(response.body.isNotEmpty ? jsonDecode(response.body)['detail'] : 'Conflicto al comprar el anuncio.');
      } else {
        throw AnuncioException(
          'Error al comprar anuncio (${response.statusCode})',
        );
      }
    } catch (e) {
      throw AnuncioException('$e');
    }
  }

  /// Returns true if the currently logged-in user is the buyer of the anuncio.
  Future<bool> comprobarComprador(int anuncioId) async {
    try {
      final token = await TokenStorage().getToken();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/$anuncioId/comprobar-comprador'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));


      if (response.statusCode == 200) {
        return jsonDecode(response.body) == true;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
