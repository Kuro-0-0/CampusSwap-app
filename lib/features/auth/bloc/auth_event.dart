part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}
