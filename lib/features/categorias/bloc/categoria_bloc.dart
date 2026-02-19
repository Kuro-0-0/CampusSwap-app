import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/models/categoria_response_model.dart';
import 'package:campusswap_app/core/services/categoria_service.dart';
import 'package:meta/meta.dart';

part 'categoria_event.dart';
part 'categoria_state.dart';

class CategoriaBloc extends Bloc<CategoriaEvent, CategoriaState> {
  final CategoriaService _categoriaService;

  CategoriaBloc({CategoriaService? categoriaService})
    : _categoriaService = categoriaService ?? CategoriaService(),
      super(CategoriaInitial()) {
    on<CargarCategorias>(_onCargarCategorias);
    on<SeleccionarCategoria>(_onSeleccionarCategoria);
  }

  Future<void> _onCargarCategorias(
    CargarCategorias event,
    Emitter<CategoriaState> emit,
  ) async {
    final selectedCategoriaId = _selectedCategoriaIdFromState(state);
    emit(CategoriaLoading(selectedCategoriaId: selectedCategoriaId));

    try {
      final categorias = await _categoriaService.obtenerCategorias();
      emit(
        CategoriaSuccess(
          categorias: categorias,
          selectedCategoriaId: selectedCategoriaId,
        ),
      );
    } on CategoriaException catch (e) {
      emit(
        CategoriaError(
          message: e.message,
          selectedCategoriaId: selectedCategoriaId,
        ),
      );
    } catch (_) {
      emit(
        CategoriaError(
          message: 'Error inesperado al cargar categorías',
          selectedCategoriaId: selectedCategoriaId,
        ),
      );
    }
  }

  void _onSeleccionarCategoria(
    SeleccionarCategoria event,
    Emitter<CategoriaState> emit,
  ) {
    final currentState = state;

    if (currentState is CategoriaSuccess) {
      emit(
        currentState.copyWith(
          selectedCategoriaId: event.categoriaId,
          clearSelectedCategoriaId: event.categoriaId == null,
        ),
      );
    }
  }

  int? _selectedCategoriaIdFromState(CategoriaState currentState) {
    if (currentState is CategoriaSuccess) {
      return currentState.selectedCategoriaId;
    }

    if (currentState is CategoriaLoading) {
      return currentState.selectedCategoriaId;
    }

    if (currentState is CategoriaError) {
      return currentState.selectedCategoriaId;
    }

    return null;
  }
}
