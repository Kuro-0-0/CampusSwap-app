import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/interfaces/profile_interface.dart';
import 'package:campusswap_app/core/services/profile_service.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileService _service;

  ProfileBloc({IProfileService? service})
      : _service = service ?? ProfileService(),
        super(ProfileInitial()) {
    on<LoadAnuncios>(_onLoadAnuncios);
    on<LoadFavoritos>(_onLoadFavoritos);
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
