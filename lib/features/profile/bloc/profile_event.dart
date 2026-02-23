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

final class PauseAnuncio extends ProfileEvent {
  final int anuncioId;
  PauseAnuncio({required this.anuncioId});
}

final class ReactivateAnuncio extends ProfileEvent {
  final int anuncioId;
  ReactivateAnuncio({required this.anuncioId});
}

final class DeleteAnuncio extends ProfileEvent {
  final int anuncioId;
  DeleteAnuncio({required this.anuncioId});
}

final class DeleteFavorito extends ProfileEvent {
  final int favoritoId;
  DeleteFavorito({required this.favoritoId});
}

final class AddFavorito extends ProfileEvent {
  final int anuncioId;
  AddFavorito({required this.anuncioId});
}
