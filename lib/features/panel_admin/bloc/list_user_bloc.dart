import 'package:campusswap_app/core/models/usuario_response_model.dart';
import 'package:campusswap_app/core/services/profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'list_user_event.dart';
part 'list_user_state.dart';

class ListUserBloc extends Bloc<ListUserEvent, ListUserState> {
  final ProfileService _profileService;

  List<UsuarioResponse> _ultimaLista = [];

  List<UsuarioResponse> get ultimaLista => _ultimaLista;

  ListUserBloc({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService(),
        super(ListUserInitial()) {
    on<GetUsuarios>(_onGetUsuarios);
    on<BloquearUsuario>(_onBloquearUsuario);
  }

  Future<void> _onGetUsuarios(
    GetUsuarios event,
    Emitter<ListUserState> emit,
  ) async {
    emit(ListUserLoading());
    try {
      final page = await _profileService.getTotalUsuarios(page: 0, size: 50);
      _ultimaLista = page.content;
      emit(ListUserSuccess(_ultimaLista));
    } on ProfileException catch (e) {
      emit(ListUserFailure(e.message));
    } catch (e) {
      emit(ListUserFailure('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onBloquearUsuario(
    BloquearUsuario event,
    Emitter<ListUserState> emit,
  ) async {
    emit(ListUserBloqueoLoading(event.usuarioId));
    try {
      await _profileService.bloquearUsuario(event.usuarioId);
      emit(ListUserBloqueoSuccess());
      add(GetUsuarios()); 
    } on ProfileException catch (e) {
      emit(ListUserBloqueoFailure(e.message));
      add(GetUsuarios()); 
    } catch (e) {
      emit(ListUserBloqueoFailure('Error inesperado: ${e.toString()}'));
      add(GetUsuarios());
    }
  }
}
