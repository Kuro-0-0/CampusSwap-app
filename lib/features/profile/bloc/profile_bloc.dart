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
    on<PauseAnuncio>(_onPauseAnuncio);
    on<ReactivateAnuncio>(_onReactivateAnuncio);
    on<DeleteAnuncio>(_onDeleteAnuncio);
    on<DeleteFavorito>(_onDeleteFavorito);
    on<AddFavorito>(_onAddFavorito);
    on<UpdateProfileImage>(_onUpdateProfileImage);
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
      emit(
        ProfileLoaded(
          usuario: usuario,
          anuncios: anuncios,
          favoritos: favoritos,
        ),
      );
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('No autorizado')) {
        emit(
          ProfileUnauthorized(
            message: 'No autorizado. Por favor, inicia sesión de nuevo.',
          ),
        );
      } else {
        emit(ProfileFailure(message: errorMsg));
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

  Future<void> _onPauseAnuncio(
    PauseAnuncio event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _service.pauseAnuncio(event.anuncioId);
      emit(
        AnuncioActionSuccess(
          message: 'Anuncio pausado correctamente',
          anuncioId: event.anuncioId,
        ),
      );
      add(LoadProfile());
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('No autorizado')) {
        emit(ProfileUnauthorized(message: errorMsg));
      } else {
        emit(ProfileFailure(message: errorMsg));
      }
    }
  }

  Future<void> _onReactivateAnuncio(
    ReactivateAnuncio event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _service.enableAnuncio(event.anuncioId);
      emit(
        AnuncioActionSuccess(
          message: 'Anuncio reactivado correctamente',
          anuncioId: event.anuncioId,
        ),
      );
      add(LoadProfile());
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('No autorizado')) {
        emit(ProfileUnauthorized(message: errorMsg));
      } else {
        emit(ProfileFailure(message: errorMsg));
      }
    }
  }

  Future<void> _onDeleteAnuncio(
    DeleteAnuncio event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _service.deleteAnuncio(event.anuncioId);
      emit(
        AnuncioActionSuccess(
          message: 'Anuncio eliminado correctamente',
          anuncioId: event.anuncioId,
        ),
      );
      add(LoadProfile());
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('No autorizado')) {
        emit(ProfileUnauthorized(message: errorMsg));
      } else {
        emit(ProfileFailure(message: errorMsg));
      }
    }
  }

  Future<void> _onDeleteFavorito(
    DeleteFavorito event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _service.deleteFavorito(event.favoritoId);
      emit(
        FavoritoDeleteSuccess(
          message: 'Favorito eliminado correctamente',
          favoritoId: event.favoritoId,
        ),
      );
      add(LoadProfile());
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('No autorizado')) {
        emit(ProfileUnauthorized(message: errorMsg));
      } else {
        emit(ProfileFailure(message: errorMsg));
      }
    }
  }

  Future<void> _onAddFavorito(
    AddFavorito event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _service.addFavorito(event.anuncioId);
      emit(
        FavoritoAddSuccess(
          message: 'Añadido a favoritos correctamente',
          anuncioId: event.anuncioId,
        ),
      );
      add(LoadProfile());
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('No autorizado')) {
        emit(ProfileUnauthorized(message: errorMsg));
      } else {
        emit(ProfileFailure(message: errorMsg));
      }
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _service.updateProfileImage(event.imagePath);
      emit(ProfileImageUpdateSuccess(message: 'Foto de perfil actualizada correctamente'));
      add(LoadProfile());
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('No autorizado')) {
        emit(ProfileUnauthorized(message: errorMsg));
      } else {
        emit(ProfileFailure(message: errorMsg));
      }
    }
  }
}
