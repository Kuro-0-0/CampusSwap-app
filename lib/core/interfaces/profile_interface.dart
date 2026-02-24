import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/models/usuario_page_response_model.dart';
import 'package:campusswap_app/core/models/usuario_response_model.dart';

abstract class IProfileService {
  Future<UsuarioResponse> getCurrentUser();
  Future<List<Anuncio>> getMisAnuncios(String usuarioId);
  Future<List<Favorito>> getFavoritos(String usuarioId);
  Future<void> pauseAnuncio(int anuncioId);
  Future<void> enableAnuncio(int anuncioId);
  Future<void> deleteAnuncio(int anuncioId);
  Future<void> deleteFavorito(int favoritoId);
  Future<void> addFavorito(int anuncioId);
  Future<UsuarioResponse> getPublicUserProfile(String usuarioId);
  Future<List<Anuncio>> getUserAnuncios(String usuarioId);
  Future<UsuarioPageResponse> getTotalUsuarios({int page = 0, int size = 10});

  Future<void> updateProfileImage(String imagePath);
}
