part of 'mensaje_bloc.dart';

@immutable
sealed class MensajeState {}

final class MensajeInitial extends MensajeState {}

class MensajeLoading extends MensajeState {}

class MensajeSuccess extends MensajeState {
  final MensajeResponse data;
  MensajeSuccess(this.data);
}

class MensajeFailure extends MensajeState {
  final String message;
  MensajeFailure({required this.message});
}
