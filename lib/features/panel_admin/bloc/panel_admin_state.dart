part of 'panel_admin_bloc.dart';

@immutable
sealed class PanelAdminState {}

final class PanelAdminInitial extends PanelAdminState {}

final class PanelAdminLoading extends PanelAdminState {}

final class PanelAdminLoaded extends PanelAdminState {
  final int totalAnuncios;
  final int usuariosActivos;
  final int categorias;
  final int reportesPendientes;
  final List<Anuncio> anunciosRecientes;

  PanelAdminLoaded({
    required this.totalAnuncios,
    required this.usuariosActivos,
    required this.categorias,
    required this.reportesPendientes,
    required this.anunciosRecientes,
  });
}

final class PanelAdminError extends PanelAdminState {
  final String message;
  PanelAdminError(this.message);
}