part of 'chat_detalle_bloc.dart';

@immutable
sealed class ChatDetalleState {}

final class ChatDetalleInitial extends ChatDetalleState {}

final class ChatDetalleLoading extends ChatDetalleState {}

final class ChatDetalleSuccess extends ChatDetalleState {
  final List<ChatMensajeResponse> mensajes;

  ChatDetalleSuccess({required this.mensajes});
}

final class ChatDetalleFailure extends ChatDetalleState {
  final String error;

  ChatDetalleFailure({required this.error});
}
