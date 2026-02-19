import 'package:campusswap_app/core/models/mensaje_response_model.dart';

abstract class MensajeInterface {
  Future<MensajeResponse> obtenerMensajes(
    int idAnuncio,
    {int page = 0, int size = 20}
  );
}