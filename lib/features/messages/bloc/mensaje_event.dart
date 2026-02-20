part of 'mensaje_bloc.dart';

@immutable
sealed class MensajeEvent {}

final class GetChats extends MensajeEvent {}
