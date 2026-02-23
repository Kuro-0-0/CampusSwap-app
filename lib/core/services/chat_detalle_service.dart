import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/chat_detalle_interface.dart';
import 'package:campusswap_app/core/models/chat_mensaje_model.dart';
import 'package:campusswap_app/core/models/enviar_mensaje_request.dart';
import 'package:campusswap_app/core/models/enviar_mensaje_response.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;



class ChatDetalleException implements Exception {
  final String message;
  const ChatDetalleException(this.message);

  @override
  String toString() => message;
}



class ChatDetalleService implements ChatDetalleInterface{

  final String _baseUrl = "${TokenStorage.baseUrl}/api/v1/mensajes";

  @override
  Future<List<ChatMensajeResponse>> obtenerMensajes({required int idAnuncio, required String idContrario})async {

    final Uri uri = Uri.parse(
      "$_baseUrl/$idAnuncio/$idContrario?sort=fechaMensaje,asc",
    );
    final http.Response response;

    try{

      final token = await TokenStorage().getToken();

      response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      } on SocketException {
      throw const ChatDetalleException(
          "No se pudo conectar al servidor. Verifica tu conexión.");
    } catch (e) {
      throw const ChatDetalleException("Error de conexión inesperado.");
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> content = body['content'] as List<dynamic>;
      return content
          .map((e) => ChatMensajeResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw const ChatDetalleException(
          "No autorizado. Por favor, inicia sesión.");
    } else if (response.statusCode == 403) {
      throw const ChatDetalleException(
          "Acceso prohibido. No tienes permisos.");
    } else if (response.statusCode == 404) {
      throw const ChatDetalleException("Recurso no encontrado.");
    } else {
      throw ChatDetalleException(
          "Error del servidor (${response.statusCode}). Intenta más tarde.");
    }


  }

  @override
  Future<EnviarMensajeResponse> enviarMensaje({
    required EnviarMensajeRequest request,
  }) async {
    final Uri uri = Uri.parse(_baseUrl);
    final http.Response response;

    try {
      final token = await TokenStorage().getToken();

      response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(request.toJson()),
      );
    } on SocketException {
      throw const ChatDetalleException(
          "No se pudo conectar al servidor. Verifica tu conexión.");
    } catch (e) {
      throw const ChatDetalleException("Error de conexión inesperado.");
    }

    if (response.statusCode == 201) {
      return EnviarMensajeResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 401) {
      throw const ChatDetalleException(
          "No autorizado. Por favor, inicia sesión.");
    } else if (response.statusCode == 403) {
      throw const ChatDetalleException(
          "Acceso prohibido. No tienes permisos.");
    } else {
      throw ChatDetalleException(
          "Error del servidor (${response.statusCode}). Intenta más tarde.");
    }
  }
}