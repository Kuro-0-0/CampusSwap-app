import 'package:campusswap_app/core/models/anuncio_request_model.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';

abstract class IAnuncioResponse {
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
  });
  Future<void> pauseAnuncio(int anuncioId);
  Future<void> enableAnuncio(int anuncioId);
  Future<void> deleteAnuncio(int anuncioId);

  Future<Anuncio> crearAnuncio(AnuncioRequestModel request);
  Future<Anuncio> editarAnuncio(int id, AnuncioRequestModel request);
}