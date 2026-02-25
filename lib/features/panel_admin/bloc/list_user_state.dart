part of 'list_user_bloc.dart';

@immutable
sealed class ListUserState {}

final class ListUserInitial extends ListUserState {}

class ListUserLoading extends ListUserState {}

final class ListUserSuccess extends ListUserState {
  final List<UsuarioResponse> usuarios;
  ListUserSuccess(this.usuarios);
}

final class ListUserFailure extends ListUserState {
  final String error;
  ListUserFailure(this.error);
}

final class ListUserBloqueoLoading extends ListUserState {
  final String usuarioId;
  ListUserBloqueoLoading(this.usuarioId);
}

final class ListUserBloqueoSuccess extends ListUserState {
final UsuarioResponse usuarioActualizado;
  ListUserBloqueoSuccess(this.usuarioActualizado);

}

final class ListUserBloqueoFailure extends ListUserState {
  final String error;
  ListUserBloqueoFailure(this.error);
}