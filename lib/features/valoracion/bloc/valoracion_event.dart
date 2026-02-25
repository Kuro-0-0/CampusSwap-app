part of 'valoracion_bloc.dart';

@immutable
abstract class ValoracionEvent {}

class SubmitValoracion extends ValoracionEvent {
  final ValoracionRequest request;

  SubmitValoracion({required this.request});
}
