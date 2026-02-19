part of 'categoria_bloc.dart';

@immutable
sealed class CategoriaState {}

final class CategoriaInitial extends CategoriaState {}

final class CategoriaLoading extends CategoriaState {
  final int? selectedCategoriaId;

  CategoriaLoading({this.selectedCategoriaId});
}

final class CategoriaSuccess extends CategoriaState {
  final List<CategoriaResponseModel> categorias;
  final int? selectedCategoriaId;

  CategoriaSuccess({required this.categorias, this.selectedCategoriaId});

  CategoriaSuccess copyWith({
    List<CategoriaResponseModel>? categorias,
    int? selectedCategoriaId,
    bool clearSelectedCategoriaId = false,
  }) {
    return CategoriaSuccess(
      categorias: categorias ?? this.categorias,
      selectedCategoriaId: clearSelectedCategoriaId
          ? null
          : (selectedCategoriaId ?? this.selectedCategoriaId),
    );
  }
}

final class CategoriaError extends CategoriaState {
  final String message;
  final int? selectedCategoriaId;

  CategoriaError({required this.message, this.selectedCategoriaId});
}
