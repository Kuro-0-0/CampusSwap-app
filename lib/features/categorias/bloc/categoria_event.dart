part of 'categoria_bloc.dart';

@immutable
sealed class CategoriaEvent {}

final class CargarCategorias extends CategoriaEvent {}

final class SeleccionarCategoria extends CategoriaEvent {
  final int? categoriaId;

  SeleccionarCategoria({required this.categoriaId});
}
