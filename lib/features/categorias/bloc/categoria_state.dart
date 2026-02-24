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
  final List<CategoriaResponseModel> filteredCategorias;
  final int? selectedCategoriaId;

  CategoriaSuccess({
    required this.categorias,
    this.selectedCategoriaId,
    List<CategoriaResponseModel>? filteredCategorias,
  }) : filteredCategorias = filteredCategorias ?? categorias;

  CategoriaSuccess copyWith({
    List<CategoriaResponseModel>? categorias,
    List<CategoriaResponseModel>? filteredCategorias,
    int? selectedCategoriaId,
    bool clearSelectedCategoriaId = false,
  }) {
    return CategoriaSuccess(
      categorias: categorias ?? this.categorias,
      filteredCategorias: filteredCategorias ?? this.filteredCategorias,
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

final class CategoriaOperationLoading extends CategoriaState {
  final List<CategoriaResponseModel> categorias;
  final String operationType; // 'create', 'update', 'delete'

  CategoriaOperationLoading({
    required this.categorias,
    required this.operationType,
  });
}

final class CategoriaOperationSuccess extends CategoriaState {
  final List<CategoriaResponseModel> categorias;
  final List<CategoriaResponseModel> filteredCategorias;
  final String message;
  final String operationType; // 'create', 'update', 'delete'

  CategoriaOperationSuccess({
    required this.categorias,
    required this.message,
    required this.operationType,
    List<CategoriaResponseModel>? filteredCategorias,
  }) : filteredCategorias = filteredCategorias ?? categorias;
}
