import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/interfaces/profile_interface.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
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
  }

  Future<void> _onLoadPublicProfile(
    LoadPublicProfile event,
    Emitter<PublicProfileState> emit,
  ) async {
    emit(PublicProfileLoading());
    try {
      final usuario = await _service.getPublicUserProfile(event.usuarioId);
      final anuncios = await _service.getUserAnuncios(usuario.id);
      emit(
        PublicProfileLoaded(
          usuario: usuario,
          anuncios: anuncios,
        ),
      );
    } catch (e) {
      emit(PublicProfileFailure(message: e.toString()));
    }
  }
}
