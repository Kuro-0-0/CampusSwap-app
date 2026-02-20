part of 'anuncio_form_bloc.dart';

@immutable
sealed class AnuncioFormEvent {}

final class SubmitAnuncio extends AnuncioFormEvent {
  final AnuncioRequestModel request;
  final int? anuncioId;
  final String? rutaImagen;

  SubmitAnuncio({required this.request, this.anuncioId, this.rutaImagen});
}