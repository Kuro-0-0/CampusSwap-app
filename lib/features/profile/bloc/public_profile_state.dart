part of 'public_profile_bloc.dart';

@immutable
sealed class PublicProfileState {}

final class PublicProfileInitial extends PublicProfileState {}

final class PublicProfileLoading extends PublicProfileState {}

final class PublicProfileLoaded extends PublicProfileState {
  final UsuarioResponse usuario;
  final List<Anuncio> anuncios;

  PublicProfileLoaded({
    required this.usuario,
    required this.anuncios,
  });
}

final class PublicProfileFailure extends PublicProfileState {
  final String message;
  PublicProfileFailure({required this.message});
}
