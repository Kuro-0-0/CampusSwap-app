import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/interfaces/profile_interface.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/models/usuario_response_model.dart';
import 'package:campusswap_app/core/services/profile_service.dart';
import 'package:meta/meta.dart';

part 'public_profile_event.dart';
part 'public_profile_state.dart';

class PublicProfileBloc extends Bloc<PublicProfileEvent, PublicProfileState> {
  final IProfileService _service;

  PublicProfileBloc({IProfileService? service})
    : _service = service ?? ProfileService(),
      super(PublicProfileInitial()) {
    on<LoadPublicProfile>(_onLoadPublicProfile);
    on<ToggleFavoritoPublicProfile>(_onToggleFavorito);
  }

  Future<void> _onLoadPublicProfile(
    LoadPublicProfile event,
    Emitter<PublicProfileState> emit,
  ) async {
    emit(PublicProfileLoading());
    try {
      // Check if user is visiting their own profile and load their favorites
      List<Favorito> myFavoritos = [];
      try {
        final currentUser = await _service.getCurrentUser();
        if (currentUser.id == event.usuarioId) {
          emit(PublicProfileIsOwnProfile());
          return;
        }
        myFavoritos = await _service.getFavoritos(currentUser.id);
      } catch (_) {
        // Not logged in or error — proceed without favorites
      }

      final usuario = await _service.getPublicUserProfile(event.usuarioId);
      final anuncios = await _service.getUserAnuncios(usuario.id);
      emit(
        PublicProfileLoaded(
          usuario: usuario,
          anuncios: anuncios,
          myFavoritos: myFavoritos,
        ),
      );
    } catch (e) {
      emit(PublicProfileFailure(message: e.toString()));
    }
  }

  Future<void> _onToggleFavorito(
    ToggleFavoritoPublicProfile event,
    Emitter<PublicProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PublicProfileLoaded) return;

    try {
      final existingFavorito = currentState.myFavoritos
          .where((f) => f.anuncio.id == event.anuncioId)
          .firstOrNull;

      if (existingFavorito != null) {
        // Already a favorite — remove it
        await _service.deleteFavorito(existingFavorito.id);
        final updatedFavoritos = currentState.myFavoritos
            .where((f) => f.id != existingFavorito.id)
            .toList();
        emit(currentState.copyWith(myFavoritos: updatedFavoritos));
      } else {
        await _service.addFavorito(event.anuncioId);
        try {
          final currentUser = await _service.getCurrentUser();
          final refreshedFavoritos = await _service.getFavoritos(currentUser.id);
          emit(currentState.copyWith(myFavoritos: refreshedFavoritos));
        } catch (_) {
        }
      }
      add(LoadPublicProfile(usuarioId: currentState.usuario.id));
    } catch (e) {
      emit(PublicProfileFailure(message: e.toString()));
    }
  }
}
