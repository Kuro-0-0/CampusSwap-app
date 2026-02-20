import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';


class LoginForm extends StatefulWidget {
  final void Function(String email, String password) onLoginTap;
  final VoidCallback onForgotPasswordTap;
  final VoidCallback onRegisterTap;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onLoginTap,
    required this.onForgotPasswordTap,
    required this.onRegisterTap,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInputField(
            label: "Correo electrónico",
            hintText: "ejemplo@colegio.edu",
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          const SizedBox(height: 20),
          
          CustomInputField(
            label: "Contraseña",
            hintText: "••••••••",
            prefixIcon: Icons.lock_outline,
            isPassword: !_isPasswordVisible,
            controller: _passwordController,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey.shade400,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPasswordTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "¿Olvidaste tu contraseña?",
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: widget.isLoading
                ? null
                : () => widget.onLoginTap(
                      _emailController.text,
                      _passwordController.text,
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Iniciar Sesión",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¿No tienes cuenta? ",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              GestureDetector(
                onTap: widget.onRegisterTap,
                child: const Text(
                  "Regístrate aquí",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}