import 'package:campusswap_app/core/models/register_request_model.dart';
import 'package:campusswap_app/core/models/register_response_model.dart';
import 'package:campusswap_app/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {

final AuthService _authService;

  RegisterBloc(this._authService) : super(RegisterInitial()) {
    on<RegisterUser>((event, emit) async {
      emit(RegisterLoading());
      try{
        final response = await _authService.register(event.registerRequest);
        emit(RegisterSuccess(response));

      }on AuthException catch(e){
        emit(RegisterFailure(e.message));
      }catch(e){
        emit(RegisterFailure("Ocurrió un error inesperado. Intenta de nuevo."));
      }
    });
  }
}
  