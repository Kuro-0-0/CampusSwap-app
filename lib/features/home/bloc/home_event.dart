part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class CargarCatalogo extends HomeEvent {
  final int page;
  final int size;
  final String sort;
  final String direction;
  final String? q;
  final int? categoriaId;
  final double? minPrecio;
  final double? maxPrecio;
  final String? tipoOperacion;
  final String? estado;

  CargarCatalogo({
    this.page = 0,
    this.size = 10,
    this.sort = 'fechaPublicacion',
    this.direction = 'DESC',
    this.q,
    this.categoriaId,
    this.minPrecio,
    this.maxPrecio,
    this.tipoOperacion,
    this.estado,
  });
}
