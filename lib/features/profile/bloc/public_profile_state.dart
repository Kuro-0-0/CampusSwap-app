part of 'public_profile_bloc.dart';

@immutable
sealed class PublicProfileState {}

final class PublicProfileInitial extends PublicProfileState {}

final class PublicProfileLoading extends PublicProfileState {}

final class PublicProfileIsOwnProfile extends PublicProfileState {}

final class PublicProfileLoaded extends PublicProfileState {
  final UsuarioResponse usuario;
  final List<Anuncio> anuncios;
  final List<Favorito> myFavoritos;
  final List<Valoracion> valoraciones;

  PublicProfileLoaded({
    required this.usuario,
    required this.anuncios,
    required this.myFavoritos,
    required this.valoraciones,
  });

  PublicProfileLoaded copyWith({
    UsuarioResponse? usuario,
    List<Anuncio>? anuncios,
    List<Favorito>? myFavoritos,
    List<Valoracion>? valoraciones,
  }) {
    return PublicProfileLoaded(
      usuario: usuario ?? this.usuario,
      anuncios: anuncios ?? this.anuncios,
      myFavoritos: myFavoritos ?? this.myFavoritos,
      valoraciones: valoraciones ?? this.valoraciones,
    );
  }
}

final class PublicProfileFailure extends PublicProfileState {
  final String message;
  PublicProfileFailure({required this.message});
}
