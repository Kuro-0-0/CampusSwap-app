part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final LoginResponse response;
  AuthSuccess({required this.response});
}

final class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}

class Unauthenticated extends AuthState {
  final bool forced;
  Unauthenticated({this.forced = false});
}
