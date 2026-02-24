import 'package:campusswap_app/core/models/categoria_request_model.dart';
import 'package:campusswap_app/core/models/categoria_response_model.dart';

abstract class ICategoriaResponse {
  Future<List<CategoriaResponseModel>> obtenerCategorias();
  Future<CategoriaResponseModel> crearCategoria(CategoriaRequestModel categoria);
  Future<CategoriaResponseModel> actualizarCategoria(int categoryId, CategoriaRequestModel categoria);
  Future<void> eliminarCategoria(int categoryId);
}
