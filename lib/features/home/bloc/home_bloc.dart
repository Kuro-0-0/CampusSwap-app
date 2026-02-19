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
    emit(HomeLoading());

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
      emit(HomeError(message: e.message));
    } catch (e) {
      emit(HomeError(message: 'Error inesperado al cargar el catálogo'));
    }
  }
}
