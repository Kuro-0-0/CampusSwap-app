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
