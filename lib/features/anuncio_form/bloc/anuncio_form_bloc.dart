import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/models/anuncio_request_model.dart';
import 'package:campusswap_app/core/services/anuncio_service.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'anuncio_form_event.dart';
part 'anuncio_form_state.dart';

class AnuncioFormBloc extends Bloc<AnuncioFormEvent, AnuncioFormState> {
  final AnuncioService _service;

  AnuncioFormBloc({AnuncioService? service})
      : _service = service ?? AnuncioService(),
        super(AnuncioFormInitial()) {
    on<SubmitAnuncio>(_onSubmitAnuncio);
  }

  Future<void> _onSubmitAnuncio(SubmitAnuncio event, Emitter<AnuncioFormState> emit) async {
    emit(AnuncioFormLoading());
    try {
      if (event.anuncioId == null) {
        await _service.crearAnuncio(event.request, event.rutaImagen!);
      } else {
        await _service.editarAnuncio(event.anuncioId!, event.request, event.rutaImagen);
      }
      emit(AnuncioFormSuccess());
    } on AnuncioException catch (e) {
      emit(AnuncioFormError(e.message));
    } catch (e) {
      emit(AnuncioFormError("Ocurrió un error inesperado."));
    }
  }
}