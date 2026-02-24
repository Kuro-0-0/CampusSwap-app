import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/models/categoria_request_model.dart';
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
    on<CrearCategoria>(_onCrearCategoria);
    on<ActualizarCategoria>(_onActualizarCategoria);
    on<EliminarCategoria>(_onEliminarCategoria);
    on<FiltrarCategorias>(_onFiltrarCategorias);
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

  Future<void> _onCrearCategoria(
    CrearCategoria event,
    Emitter<CategoriaState> emit,
  ) async {
    final currentState = state;

    if (currentState is! CategoriaSuccess) return;

    emit(CategoriaOperationLoading(
      categorias: currentState.categorias,
      operationType: 'create',
    ));

    try {
      final newCategoria = CategoriaRequestModel(
        nombre: event.nombre,
        descripcion: event.descripcion,
      );

      final response = await _categoriaService.crearCategoria(newCategoria);
      
      final updatedCategorias = [...currentState.categorias, response];
      emit(
        CategoriaOperationSuccess(
          categorias: updatedCategorias,
          filteredCategorias: updatedCategorias,
          message: 'Categoría creada exitosamente',
          operationType: 'create',
        ),
      );

      // Return to success state
      emit(CategoriaSuccess(
        categorias: updatedCategorias,
        filteredCategorias: updatedCategorias,
      ));
    } on CategoriaException catch (e) {
      emit(
        CategoriaError(
          message: e.message,
        ),
      );
    } catch (e) {
      emit(
        CategoriaError(
          message: 'Error inesperado al crear categoría',
        ),
      );
    }
  }

  Future<void> _onActualizarCategoria(
    ActualizarCategoria event,
    Emitter<CategoriaState> emit,
  ) async {
    final currentState = state;

    if (currentState is! CategoriaSuccess) return;

    emit(CategoriaOperationLoading(
      categorias: currentState.categorias,
      operationType: 'update',
    ));

    try {
      final updateCategoria = CategoriaRequestModel(
        nombre: event.nombre,
        descripcion: event.descripcion,
      );

      await _categoriaService.actualizarCategoria(event.id, updateCategoria);
      
      final updatedCategorias = currentState.categorias.map((cat) {
        if (cat.id == event.id) {
          return CategoriaResponseModel(
            id: cat.id,
            nombre: event.nombre,
            descripcion: event.descripcion,
          );
        }
        return cat;
      }).toList();

      emit(
        CategoriaOperationSuccess(
          categorias: updatedCategorias,
          filteredCategorias: updatedCategorias,
          message: 'Categoría actualizada exitosamente',
          operationType: 'update',
        ),
      );

      // Return to success state
      emit(CategoriaSuccess(
        categorias: updatedCategorias,
        filteredCategorias: updatedCategorias,
      ));
    } on CategoriaException catch (e) {
      emit(
        CategoriaError(
          message: e.message,
        ),
      );
    } catch (e) {
      emit(
        CategoriaError(
          message: 'Error inesperado al actualizar categoría',
        ),
      );
    }
  }

  Future<void> _onEliminarCategoria(
    EliminarCategoria event,
    Emitter<CategoriaState> emit,
  ) async {
    final currentState = state;

    if (currentState is! CategoriaSuccess) return;

    emit(CategoriaOperationLoading(
      categorias: currentState.categorias,
      operationType: 'delete',
    ));

    try {
      await _categoriaService.eliminarCategoria(event.id);
      
      final updatedCategorias = currentState.categorias
          .where((cat) => cat.id != event.id)
          .toList();

      emit(
        CategoriaOperationSuccess(
          categorias: updatedCategorias,
          filteredCategorias: updatedCategorias,
          message: 'Categoría eliminada exitosamente',
          operationType: 'delete',
        ),
      );

      // Return to success state
      emit(CategoriaSuccess(
        categorias: updatedCategorias,
        filteredCategorias: updatedCategorias,
      ));
    } on CategoriaException catch (e) {
      // For conflict errors (409), show snack bar but return to list view
      if (e.code == 'conflict') {
        emit(
          CategoriaError(
            message: e.message,
          ),
        );
        // Return to success state to avoid full screen error
        emit(CategoriaSuccess(
          categorias: currentState.categorias,
          filteredCategorias: currentState.filteredCategorias,
        ));
      } else {
        emit(
          CategoriaError(
            message: e.message,
          ),
        );
      }
    } catch (e) {
      emit(
        CategoriaError(
          message: 'Error inesperado al eliminar categoría',
        ),
      );
    }
  }

  void _onFiltrarCategorias(
    FiltrarCategorias event,
    Emitter<CategoriaState> emit,
  ) {
    final currentState = state;

    if (currentState is CategoriaSuccess) {
      final query = event.query.toLowerCase();
      
      final filtered = currentState.categorias
          .where((cat) =>
              cat.nombre.toLowerCase().contains(query) ||
              cat.descripcion.toLowerCase().contains(query))
          .toList();

      emit(
        currentState.copyWith(filteredCategorias: filtered),
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
