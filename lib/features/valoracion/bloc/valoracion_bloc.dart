import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/models/crear_valoracion_model.dart';
import 'package:campusswap_app/core/models/valoracion_request_model.dart';
import 'package:campusswap_app/core/models/valoracion_response_model.dart';
import 'package:campusswap_app/core/services/valoracion_service.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'valoracion_event.dart';
part 'valoracion_state.dart';

class ValoracionBloc extends Bloc<ValoracionEvent, ValoracionState> {
  final ValoracionService _service;

  ValoracionBloc({ValoracionService? service})
      : _service = service ?? ValoracionService(),
        super(ValoracionInitial()) {
    on<SubmitValoracion>(_onSubmitValoracion);
  }

  Future<void> _onSubmitValoracion(SubmitValoracion event, Emitter<ValoracionState> emit) async {
    emit(ValoracionLoading());
    try {
      final response = await _service.crearValoracion(event.request);
      emit(ValoracionSuccess(response: response));
    } on ValoracionException catch (e) {
      emit(ValoracionError(e.message));
    } catch (e) {
      emit(ValoracionError("Ocurrió un error inesperado."));
    }
  }
}
