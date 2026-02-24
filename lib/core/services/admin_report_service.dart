import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/models/reporte_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class AdminReportException implements Exception {
  final String message;
  const AdminReportException(this.message);

  @override
  String toString() => message;
}

class AdminReportService {
  final String _baseUrl = "${TokenStorage.baseUrl}/api/v1/admin/reportes";
  final String _anunciosUrl = "${TokenStorage.baseUrl}/api/v1/anuncios";

  /// Obtiene la lista de reportes pendientes
  Future<ReporteResponseModel> obtenerReportes({
    int page = 0,
    int size = 10,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };

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
      throw const AdminReportException(
        "No se pudo conectar al servidor. Verifica tu conexión.",
      );
    } catch (e) {
      throw const AdminReportException("Error de conexión inesperado.");
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return ReporteResponseModel.fromJson(body);
    } else if (response.statusCode == 401) {
      TokenStorage.triggerLogout();
      throw const AdminReportException("No autorizado. Por favor, inicia sesión.");
    } else if (response.statusCode == 403) {
      throw const AdminReportException(
        "Acceso prohibido. No tienes permisos para acceder a esta sección.",
      );
    } else {
      throw AdminReportException(
        "Error al cargar reportes (${response.statusCode}). Intenta más tarde.",
      );
    }
  }

  /// Ignora los reportes de un anuncio (elimina los reportes)
  Future<void> ignorarReportes(int anuncioId) async {
    final Uri uri = Uri.parse("$_baseUrl/$anuncioId");

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
      throw const AdminReportException(
        "No se pudo conectar al servidor. Verifica tu conexión.",
      );
    } catch (e) {
      throw const AdminReportException("Error de conexión inesperado.");
    }

    if (response.statusCode == 204 || response.statusCode == 200) {
      // Éxito
      return;
    } else if (response.statusCode == 401) {
      TokenStorage.triggerLogout();
      throw const AdminReportException("No autorizado. Por favor, inicia sesión.");
    } else if (response.statusCode == 403) {
      throw const AdminReportException(
        "Acceso prohibido. No tienes permisos para esta acción.",
      );
    } else if (response.statusCode == 404) {
      throw const AdminReportException("Los reportes no fueron encontrados.");
    } else {
      throw AdminReportException(
        "Error al ignorar reportes (${response.statusCode}). Intenta más tarde.",
      );
    }
  }

  /// Elimina un anuncio reportado
  Future<void> eliminarAnuncio(int anuncioId) async {
    final Uri uri = Uri.parse("$_anunciosUrl/$anuncioId");

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
      throw const AdminReportException(
        "No se pudo conectar al servidor. Verifica tu conexión.",
      );
    } catch (e) {
      throw const AdminReportException("Error de conexión inesperado.");
    }

    if (response.statusCode == 204 || response.statusCode == 200) {
      // Éxito
      return;
    } else if (response.statusCode == 401) {
      TokenStorage.triggerLogout();
      throw const AdminReportException("No autorizado. Por favor, inicia sesión.");
    } else if (response.statusCode == 403) {
      throw const AdminReportException(
        "Acceso prohibido. No tienes permisos para esta acción.",
      );
    } else if (response.statusCode == 404) {
      throw const AdminReportException("El anuncio no fue encontrado.");
    } else {
      throw AdminReportException(
        "Error al eliminar anuncio (${response.statusCode}). Intenta más tarde.",
      );
    }
  }
}
