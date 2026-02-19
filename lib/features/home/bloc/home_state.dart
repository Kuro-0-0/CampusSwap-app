part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeRefreshing extends HomeState {
  final AnuncioResponseModel catalogo;

  HomeRefreshing({required this.catalogo});
}

final class HomeSuccess extends HomeState {
  final AnuncioResponseModel catalogo;

  HomeSuccess({required this.catalogo});
}

final class HomeRefreshError extends HomeState {
  final String message;
  final AnuncioResponseModel catalogo;

  HomeRefreshError({required this.message, required this.catalogo});
}

final class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}
