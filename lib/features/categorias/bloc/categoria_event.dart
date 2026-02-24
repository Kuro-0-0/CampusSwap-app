part of 'categoria_bloc.dart';

@immutable
sealed class CategoriaEvent {}

final class CargarCategorias extends CategoriaEvent {}

final class SeleccionarCategoria extends CategoriaEvent {
  final int? categoriaId;

  SeleccionarCategoria({required this.categoriaId});
}

final class CrearCategoria extends CategoriaEvent {
  final String nombre;
  final String descripcion;

  CrearCategoria({required this.nombre, required this.descripcion});
}

final class ActualizarCategoria extends CategoriaEvent {
  final int id;
  final String nombre;
  final String descripcion;

  ActualizarCategoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });
}

final class EliminarCategoria extends CategoriaEvent {
  final int id;

  EliminarCategoria({required this.id});
}

final class FiltrarCategorias extends CategoriaEvent {
  final String query;

  FiltrarCategorias({required this.query});
}
