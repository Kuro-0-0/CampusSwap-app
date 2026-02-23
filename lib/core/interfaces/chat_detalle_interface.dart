import 'package:campusswap_app/core/models/chat_mensaje_model.dart';

abstract class ChatDetalleInterface {
  Future<List<ChatMensajeResponse>> obtenerMensajes({
    required int idAnuncio,
    required String idContrario});
}