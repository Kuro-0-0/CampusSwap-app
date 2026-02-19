import 'package:campusswap_app/core/models/login_request_model.dart';
import 'package:campusswap_app/core/models/login_response_model.dart';

abstract class IAuthService {

  Future<LoginResponse> login(LoginRequest request);

}