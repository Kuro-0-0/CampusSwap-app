import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/models/usuario_response_model.dart';

abstract class IProfileService {
  Future<UsuarioResponse> getCurrentUser();
  Future<List<Anuncio>> getMisAnuncios(String usuarioId);
  Future<List<Favorito>> getFavoritos(String usuarioId);
}
