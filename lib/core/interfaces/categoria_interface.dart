import 'package:campusswap_app/core/models/categoria_response_model.dart';

abstract class ICategoriaResponse {
  Future<List<CategoriaResponseModel>> obtenerCategorias();
}
