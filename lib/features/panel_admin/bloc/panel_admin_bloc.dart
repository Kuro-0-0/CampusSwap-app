import 'package:bloc/bloc.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/services/admin_report_service.dart';
import 'package:campusswap_app/core/services/anuncio_service.dart';
import 'package:campusswap_app/core/services/categoria_service.dart';
import 'package:campusswap_app/core/services/profile_service.dart';
import 'package:meta/meta.dart';

part 'panel_admin_event.dart';
part 'panel_admin_state.dart';

class PanelAdminBloc extends Bloc<PanelAdminEvent, PanelAdminState> {
  final AnuncioService _anuncioService = AnuncioService();
  final CategoriaService _categoriaService = CategoriaService();
  final ProfileService _profileService = ProfileService();
  final AdminReportService _adminReportService = AdminReportService();
  PanelAdminBloc() : super(PanelAdminLoading()) {
    on<CargarEstadisticas>(_onCargarEstadisticas);
  }

  Future<void> _onCargarEstadisticas(CargarEstadisticas event, Emitter<PanelAdminState> emit) async {
    emit(PanelAdminLoading());
    try {
      final listaCategorias = await _categoriaService.obtenerCategorias();
      final totalCategorias = listaCategorias.length;

      final catalogo = await _anuncioService.obtenerCatalogo(page: 0, size: 5);
      final totalAnuncios = catalogo.page.totalElements; 
      final ultimosAnuncios = catalogo.content;

      final usuariosPage = await _profileService.getTotalUsuarios(page: 0, size: 1); 
      final totalUsuarios = usuariosPage.totalElements;

      final reportesPage = await _adminReportService.obtenerReportes(page: 0, size: 1);
      final totalReportesPendientes = reportesPage.page.totalElements;

      emit(PanelAdminLoaded(
        totalAnuncios: totalAnuncios,
        usuariosActivos: totalUsuarios,
        categorias: totalCategorias,
        reportesPendientes: totalReportesPendientes,
        anunciosRecientes: ultimosAnuncios,
      ));
    } catch (e) {
      emit(PanelAdminError("Error al cargar estadísticas del servidor."));
    }
  }
}

