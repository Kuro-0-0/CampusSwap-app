import 'package:campusswap_app/core/models/chat_mensaje_model.dart';
import 'package:campusswap_app/core/services/chat_detalle_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_detalle_event.dart';
part 'chat_detalle_state.dart';

class ChatDetalleBloc extends Bloc<ChatDetalleEvent, ChatDetalleState> {
  final ChatDetalleService _chatDetalleService = ChatDetalleService();

  ChatDetalleBloc() : super(ChatDetalleInitial()) {
    on<GetChatEspecifico>((event, emit) async {
      emit(ChatDetalleLoading());
      try {
        final mensajes = await _chatDetalleService.obtenerMensajes(
          idAnuncio: event.idAnuncio,
          idContrario: event.idContrario,
        );
        emit(ChatDetalleSuccess(mensajes: mensajes));
      } on ChatDetalleException catch (e) {
        emit(ChatDetalleFailure(error: e.message));
      } catch (e) {
        emit(ChatDetalleFailure(error: "Error inesperado: ${e.toString()}"));
      }
    });
  }
}
