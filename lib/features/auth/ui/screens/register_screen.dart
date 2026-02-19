import 'package:campusswap_app/core/models/register_request_model.dart';
import 'package:campusswap_app/core/services/auth_service.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/auth/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/register_header.dart';
import '../widgets/register_form_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late RegisterBloc _registerBloc;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _registerBloc = RegisterBloc(AuthService());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _registerBloc.close();
    super.dispose();
  }

  void _onRegisterTap() {
    if (_formKey.currentState!.validate()) {
      final request = RegisterRequest(
        nombre: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        repeatPassword: _confirmPasswordController.text.trim(),
      );
      _registerBloc.add(RegisterUser(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: _registerBloc,
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro exitoso. Por favor, inicia sesión.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: SizedBox(
              height: size.height > 800 ? size.height : 850,
              child: Stack(
                children: [
                  Container(
                    height: size.height * 0.40,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          RegisterHeader(
                            onBackTap: () => Navigator.pop(context),
                          ),

                          const SizedBox(height: 20),

                          BlocBuilder<RegisterBloc, RegisterState>(
                            builder: (context, state) {
                              final isLoading = state is RegisterLoading;
                              return RegisterFormCard(
                                formKey: _formKey,
                                nameController: _nameController,
                                usernameController: _usernameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                confirmPasswordController:
                                    _confirmPasswordController,
                                isLoading: isLoading,
                                onRegisterTap: _onRegisterTap,
                                onLoginTap: () => Navigator.pop(context),
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
