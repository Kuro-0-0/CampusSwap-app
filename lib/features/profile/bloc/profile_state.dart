part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final UsuarioResponse usuario;
  final List<Anuncio> anuncios;
  final List<Favorito> favoritos;

  ProfileLoaded({
    required this.usuario,
    required this.anuncios,
    required this.favoritos,
  });
}

final class ProfileAnunciosLoaded extends ProfileState {
  final List<Anuncio> anuncios;
  ProfileAnunciosLoaded({required this.anuncios});
}

final class ProfileFavoritosLoaded extends ProfileState {
  final List<Favorito> favoritos;
  ProfileFavoritosLoaded({required this.favoritos});
}

final class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure({required this.message});
}

class ProfileUnauthorized extends ProfileState {
  final String message;
  ProfileUnauthorized({required this.message});
}
final class AnuncioActionSuccess extends ProfileState {
  final String message;
  final int anuncioId;
  AnuncioActionSuccess({required this.message, required this.anuncioId});
}

final class FavoritoDeleteSuccess extends ProfileState {
  final String message;
  final int favoritoId;
  FavoritoDeleteSuccess({required this.message, required this.favoritoId});
}