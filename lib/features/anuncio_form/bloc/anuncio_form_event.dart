part of 'anuncio_form_bloc.dart';

@immutable
sealed class AnuncioFormEvent {}

final class SubmitAnuncio extends AnuncioFormEvent {
  final AnuncioRequestModel request;
  final int? anuncioId;

  SubmitAnuncio({required this.request, this.anuncioId});
}