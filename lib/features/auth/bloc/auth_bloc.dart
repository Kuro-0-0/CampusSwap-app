import 'package:campusswap_app/core/models/login_request_model.dart';
import 'package:campusswap_app/core/models/login_response_model.dart';
import 'package:campusswap_app/core/services/auth_service.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    if (event.email.trim().isEmpty || event.password.trim().isEmpty) {
      emit(AuthFailure(message: "Por favor, completa todos los campos."));
      return;
    }

    try {
      final response = await _authService.login(
        LoginRequest(email: event.email.trim(), password: event.password),
      ).timeout(const Duration(seconds: 10));
      final storage = TokenStorage();
      await storage.saveToken(response.accessToken);
      emit(AuthSuccess(response: response));
    } on AuthException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (e) {
      emit(AuthFailure(message: "Ocurrió un error inesperado. Intenta de nuevo."));
    }
  }
}
