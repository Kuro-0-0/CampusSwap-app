part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

final class RegisterUser extends RegisterEvent{
  final RegisterRequest registerRequest;
  RegisterUser(this.registerRequest);
}


