import 'package:campusswap_app/core/models/mensaje_response_model.dart';
import 'package:campusswap_app/core/services/auth_service.dart';
import 'package:campusswap_app/core/services/mensaje_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'mensaje_event.dart';
part 'mensaje_state.dart';

class MensajeBloc extends Bloc<MensajeEvent, MensajeState> {
  final MensajeService _mensajeService;

  MensajeBloc({MensajeService? mensajeService})
      : _mensajeService = mensajeService ?? MensajeService(),
        super(MensajeInitial()) {
    on<ObtenerMensajes>(_onObtenerMensajes);
  }

  Future<void> _onObtenerMensajes(
    ObtenerMensajes event,
    Emitter<MensajeState> emit,
  ) async {
    emit(MensajeLoading());

    try {
      final response = await _mensajeService
          .obtenerMensajes(event.idAnuncio)
          .timeout(const Duration(seconds: 10));
      emit(MensajeSuccess(response));
    } on AuthException catch (e) {
      emit(MensajeFailure(message: e.message));
    } catch (e) {
      emit(MensajeFailure(message: "Ocurrió un error inesperado. Intenta de nuevo."));
    }
  }
}
