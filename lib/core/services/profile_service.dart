import 'dart:convert';
import 'dart:io';

import 'package:campusswap_app/core/interfaces/profile_interface.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/models/usuario_page_response_model.dart';
import 'package:campusswap_app/core/models/usuario_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

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
        print('Error al obtener anuncios: ${response.statusCode} - ${response.body}');
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
        Uri.parse('${TokenStorage.baseUrl}/api/v1/favoritos/personal'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final favoriteResponse = FavoriteResponse.fromJson(body);
        return favoriteResponse.content;
      } else if (response.statusCode == 401) {
        TokenStorage().deleteToken();
        throw const ProfileException('No autorizado. Por favor, inicia sesión de nuevo.');
      } else {
        print('Error al obtener favoritos: ${response.statusCode} - ${response.body}');
        throw ProfileException('Error al obtener favoritos (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
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
        TokenStorage.triggerLogout();
        throw const ProfileException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const ProfileException('No tienes permiso para realizar esta acción.');
      } else if (response.statusCode == 404) {
        throw const ProfileException('Anuncio no encontrado.');
      } else {
        print('Error al alternar estado del anuncio (${response.body})');
        throw ProfileException('Error al alternar estado del anuncio (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }

  @override
  Future<void> deleteAnuncio(int anuncioId) async {
    try {
      final token = await _storage.getToken();
      final response = await http.delete(
        Uri.parse('${TokenStorage.baseUrl}/api/v1/anuncios/$anuncioId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const ProfileException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const ProfileException('No tienes permiso para eliminar este anuncio.');
      } else if (response.statusCode == 404) {
        throw const ProfileException('Anuncio no encontrado.');
      } else {
        print('Error al eliminar anuncio (${response.body})');
        throw ProfileException('Error al eliminar anuncio (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }

  @override
  Future<void> deleteFavorito(int favoritoId) async {
    try {
      final token = await _storage.getToken();
      final response = await http.delete(
        Uri.parse('${TokenStorage.baseUrl}/api/v1/favoritos/$favoritoId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const ProfileException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const ProfileException('No tienes permiso para eliminar este favorito.');
      } else if (response.statusCode == 404) {
        throw const ProfileException('Favorito no encontrado.');
      } else {
        throw ProfileException('Error al eliminar favorito (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }

 @override
  Future<void> addFavorito(int anuncioId) async {
    try {
      final token = await _storage.getToken();
      
      final response = await http.post(
        Uri.parse('${TokenStorage.baseUrl}/api/v1/favoritos'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'anuncioId': anuncioId
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const ProfileException('No autorizado. Por favor, inicia sesión.');
      } else {
        throw ProfileException('Error al añadir favorito (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }

  @override
  Future<UsuarioResponse> getPublicUserProfile(String usuarioId) async {
    try {
      final token = await _storage.getToken();
      final response = await http.get(
        Uri.parse('${TokenStorage.baseUrl}/api/v1/usuarios/$usuarioId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return UsuarioResponse.fromJson(body);
      } else if (response.statusCode == 404) {
        print(  'Usuario no encontrado: ${response.body}');
        throw const ProfileException('Usuario no encontrado.');
      } else {
        throw ProfileException('Error al obtener perfil de usuario (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }

  @override
  Future<List<Anuncio>> getUserAnuncios(String usuarioId) async {
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
      } else if (response.statusCode == 404) {
        print('Usuario no encontrado: ${response.body}');
        throw const ProfileException('Usuario no encontrado.');
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
  Future<UsuarioPageResponse> getTotalUsuarios({int page = 0, int size = 20}) async {
    try {
      final token = await _storage.getToken();

      final response = await http.get(
        Uri.parse('${TokenStorage.baseUrl}/api/v1/admin/usuarios?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return UsuarioPageResponse.fromJson(body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        TokenStorage.triggerLogout();
        throw const ProfileException('No tienes permisos de administrador.');
      } else {
        throw ProfileException('Error al obtener total de usuarios (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }

  @override
  Future<void> updateProfileImage(String imagePath) async {
    try {
      final token = await _storage.getToken();
      final uri = Uri.parse('${TokenStorage.baseUrl}/api/v1/usuarios/foto-perfil');
      final request = http.MultipartRequest('PUT', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final mimeType = lookupMimeType(imagePath);
      if (mimeType != null) {
        final subTypePart = mimeType.split('/')[1];
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imagePath,
            contentType: http.MediaType('image', subTypePart),
          ),
        );
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        TokenStorage.triggerLogout();
        throw const ProfileException('No autorizado. Por favor, inicia sesión.');
      } else {
        throw ProfileException('Error al actualizar imagen (${response.statusCode})');
      }
    } on SocketException {
      throw const ProfileException('No se pudo conectar al servidor.');
    } catch (e) {
      throw ProfileException('Error inesperado: $e');
    }
  }
}
