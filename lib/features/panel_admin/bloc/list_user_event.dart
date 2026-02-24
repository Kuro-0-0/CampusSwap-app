part of 'list_user_bloc.dart';

@immutable
sealed class ListUserEvent {}

final class GetUsuarios extends ListUserEvent{}

final class BloquearUsuario extends ListUserEvent {
  final String usuarioId;
  BloquearUsuario(this.usuarioId);
}
