
import 'package:campusswap_app/core/models/mensaje_response_model.dart';
import 'package:campusswap_app/core/services/mensaje_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'mensaje_event.dart';
part 'mensaje_state.dart';

class MensajeBloc extends Bloc<MensajeEvent, MensajeState> {
  final MensajeService _mensajeService = MensajeService();

  MensajeBloc() : super(MensajeInitial()) {
    on<GetChats>((event, emit) async {
      emit(MensajeLoading());
      try {
        final response = await _mensajeService.getChats();
        emit(MensajeSuccess(response));
      } on MensajeException catch (e) {
        emit(MensajeFailure(message: e.message));
      } catch (e) {
        emit(MensajeFailure(message: "Error inesperado: ${e.toString()}"));
      }
    });
  }
}
