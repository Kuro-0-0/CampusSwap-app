

import 'package:campusswap_app/core/models/register_response_model.dart';

import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';

abstract class IAuthService {

  Future<LoginResponse> login(LoginRequest request);
  Future<RegisterResponse> register(RegisterRequest request);

}