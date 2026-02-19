part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class LoadProfile extends ProfileEvent {}

final class LoadAnuncios extends ProfileEvent {
  final String usuarioId;
  LoadAnuncios({required this.usuarioId});
}

final class LoadFavoritos extends ProfileEvent {
  final String usuarioId;
  LoadFavoritos({required this.usuarioId});
}
