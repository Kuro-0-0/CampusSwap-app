import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/profile_interface.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
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
  Future<List<Anuncio>> getMisAnuncios(String usuarioId) async {
    try {
      final token = await _storage.getToken();
      final response = await http.get(
        Uri.parse('${TokenStorage.baseUrl}/api/v1/anuncios/usuario/$usuarioId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final anuncioResponse = AnuncioResponse.fromJson(body);
        return anuncioResponse.content;
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
        Uri.parse('${TokenStorage.baseUrl}/api/v1/favoritos/usuario/$usuarioId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final favoriteResponse = FavoriteResponse.fromJson(body);
        return favoriteResponse.content;
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
