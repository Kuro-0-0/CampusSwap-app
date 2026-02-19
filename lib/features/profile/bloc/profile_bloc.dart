import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/interfaces/profile_interface.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/models/usuario_response_model.dart';
import 'package:campusswap_app/core/services/profile_service.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileService _service;

  ProfileBloc({IProfileService? service})
      : _service = service ?? ProfileService(),
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadAnuncios>(_onLoadAnuncios);
    on<LoadFavoritos>(_onLoadFavoritos);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final usuario = await _service.getCurrentUser();
      final anuncios = await _service.getMisAnuncios(usuario.id);
      final favoritos = await _service.getFavoritos(usuario.id);
      emit(ProfileLoaded(
        usuario: usuario,
        anuncios: anuncios,
        favoritos: favoritos,
      ));
    } catch (e) {

      if (e is ProfileException && e.message.contains('No autorizado')) {
        
        emit(ProfileUnauthorized(message: 'No autorizado. Por favor, inicia sesión de nuevo.'));
      } else {
        emit(ProfileFailure(message: e.toString()));
      }

    }
  }

  Future<void> _onLoadAnuncios(
    LoadAnuncios event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final anuncios = await _service.getMisAnuncios(event.usuarioId);
      emit(ProfileAnunciosLoaded(anuncios: anuncios));
    } catch (e) {
      emit(ProfileFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadFavoritos(
    LoadFavoritos event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final favoritos = await _service.getFavoritos(event.usuarioId);
      emit(ProfileFavoritosLoaded(favoritos: favoritos));
    } catch (e) {
      emit(ProfileFailure(message: e.toString()));
    }
  }
}
