import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/profile_interface.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/models/usuario_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class ProfileException implements Exception {
  final String message;
  const ProfileException(this.message);

  @override
  String toString() => message;
}

class ProfileService implements IProfileService {
  final TokenStorage _storage = TokenStorage();

  @override
  Future<UsuarioResponse> getCurrentUser() async {
    try {

      final token = await _storage.getToken();
      final response = await http.get(
        Uri.parse('${TokenStorage.baseUrl}/api/v1/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return UsuarioResponse.fromJson(body);
      } else if (response.statusCode == 401) {
        TokenStorage().deleteToken();
        throw const ProfileException('No autorizado. Por favor, inicia sesión de nuevo.');      
      } else {
        throw ProfileException('Error al obtener usuario (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }

  @override
  Future<List<Anuncio>> getMisAnuncios(String usuarioId) async {
    try {
      final token = await _storage.getToken();
      final response = await http.get(
        Uri.parse('${TokenStorage.baseUrl}/api/v1/anuncios/$usuarioId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final anuncioResponse = AnuncioResponseModel.fromJson(body);
        return anuncioResponse.content;
      } else if (response.statusCode == 401) {
        TokenStorage().deleteToken();
        throw const ProfileException('No autorizado. Por favor, inicia sesión de nuevo.');
      } else {
        throw ProfileException('Error al obtener anuncios (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }

  @override
  Future<List<Favorito>> getFavoritos(String usuarioId) async {
    try {
      final token = await _storage.getToken();
      final response = await http.get(
        Uri.parse('${TokenStorage.baseUrl}/api/v1/favoritos'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final favoriteResponse = FavoriteResponse.fromJson(body);
        return favoriteResponse.content;
      } else if (response.statusCode == 401) {
        TokenStorage().deleteToken();
        throw const ProfileException('No autorizado. Por favor, inicia sesión de nuevo.');
      } else {
        throw ProfileException('Error al obtener favoritos (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }
}
