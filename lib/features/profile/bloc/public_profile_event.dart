part of 'public_profile_bloc.dart';

@immutable
sealed class PublicProfileEvent {}

final class LoadPublicProfile extends PublicProfileEvent {
  final String usuarioId;
  LoadPublicProfile({required this.usuarioId});
}
