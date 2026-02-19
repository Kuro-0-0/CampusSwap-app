part of 'mensaje_bloc.dart';

@immutable
sealed class MensajeEvent {}

class ObtenerMensajes extends MensajeEvent{
  final int idAnuncio;
  ObtenerMensajes(this.idAnuncio);
}
