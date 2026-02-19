part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

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
