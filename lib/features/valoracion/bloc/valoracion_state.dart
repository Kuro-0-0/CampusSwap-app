part of 'valoracion_bloc.dart';

@immutable
abstract class ValoracionState {}

class ValoracionInitial extends ValoracionState {}

class ValoracionLoading extends ValoracionState {}

class ValoracionSuccess extends ValoracionState {
  final Valoracion response;

  ValoracionSuccess({required this.response});
}

class ValoracionError extends ValoracionState {
  final String message;

  ValoracionError(this.message);
}
