import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/services/anuncio_service.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AnuncioService _anuncioService;

  HomeBloc({AnuncioService? anuncioService})
    : _anuncioService = anuncioService ?? AnuncioService(),
      super(HomeInitial()) {
    on<CargarCatalogo>(_onCargarCatalogo);
  }

  Future<void> _onCargarCatalogo(
    CargarCatalogo event,
    Emitter<HomeState> emit,
  ) async {
    final previousCatalogo = _catalogoFromState(state);

    if (previousCatalogo != null) {
      emit(HomeRefreshing(catalogo: previousCatalogo));
    } else {
      emit(HomeLoading());
    }

    try {
      final catalogo = await _anuncioService.obtenerCatalogo(
        page: event.page,
        size: event.size,
        sort: event.sort,
        direction: event.direction,
        q: event.q,
        categoriaId: event.categoriaId,
        minPrecio: event.minPrecio,
        maxPrecio: event.maxPrecio,
        tipoOperacion: event.tipoOperacion,
        estado: event.estado,
      );

      emit(HomeSuccess(catalogo: catalogo));
    } on AnuncioException catch (e) {
      if (previousCatalogo != null) {
        emit(HomeRefreshError(message: e.message, catalogo: previousCatalogo));
      } else {
        emit(HomeError(message: e.message));
      }
    } catch (e) {
      if (previousCatalogo != null) {
        emit(
          HomeRefreshError(
            message: 'Error inesperado al cargar el catálogo',
            catalogo: previousCatalogo,
          ),
        );
      } else {
        emit(HomeError(message: 'Error inesperado al cargar el catálogo'));
      }
    }
  }

  AnuncioResponseModel? _catalogoFromState(HomeState currentState) {
    if (currentState is HomeSuccess) {
      return currentState.catalogo;
    }

    if (currentState is HomeRefreshing) {
      return currentState.catalogo;
    }

    if (currentState is HomeRefreshError) {
      return currentState.catalogo;
    }

    return null;
  }
}
