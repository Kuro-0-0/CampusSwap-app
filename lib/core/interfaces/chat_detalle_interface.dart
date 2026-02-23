import 'package:campusswap_app/core/models/chat_mensaje_model.dart';
import 'package:campusswap_app/core/models/enviar_mensaje_request.dart';
import 'package:campusswap_app/core/models/enviar_mensaje_response.dart';

abstract class ChatDetalleInterface {
  Future<List<ChatMensajeResponse>> obtenerMensajes({
    required int idAnuncio,
    required String idContrario});

  Future<EnviarMensajeResponse> enviarMensaje({
    required EnviarMensajeRequest request,
  });
}