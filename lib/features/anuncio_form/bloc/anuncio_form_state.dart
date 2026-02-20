part of 'anuncio_form_bloc.dart';

@immutable
sealed class AnuncioFormState {}

final class AnuncioFormInitial extends AnuncioFormState {}
final class AnuncioFormLoading extends AnuncioFormState {}
final class AnuncioFormSuccess extends AnuncioFormState {}
final class AnuncioFormError extends AnuncioFormState {
  final String message;
  AnuncioFormError(this.message);
}