
import 'package:campusswap_app/core/models/mensaje_response_model.dart';

abstract class MensajesInterface {
  Future<MensajeResponse> getChats({int page = 0, int size = 20});
}
