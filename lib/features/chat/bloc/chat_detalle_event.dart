part of 'chat_detalle_bloc.dart';

@immutable
sealed class ChatDetalleEvent {}

final class GetChatEspecifico extends ChatDetalleEvent {
  final int idAnuncio;
  final String idContrario;

  GetChatEspecifico({
    required this.idAnuncio,
    required this.idContrario,
  });
}

  final class EnviarMensaje extends ChatDetalleEvent {
    final String contenido;
    final int anuncioId;
    final String receptorId;

    EnviarMensaje({
      required this.contenido,
      required this.anuncioId,
      required this.receptorId,
    });
  
}
