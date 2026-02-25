import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';

class RegisterFormCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onRegisterTap;
  final VoidCallback onLoginTap;

  const RegisterFormCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onRegisterTap,
    required this.onLoginTap,
  });

  @override
  State<RegisterFormCard> createState() => _RegisterFormCardState();
}

class _RegisterFormCardState extends State<RegisterFormCard> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            CustomInputField(
              label: "Nombre completo",
              hintText: "Ej. Juan Pérez",
              prefixIcon: Icons.person_outline,
              controller: widget.nameController,
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomInputField(
              label: "Nombre de usuario",
              hintText: "Ej. juanperez99",
              prefixIcon: Icons.alternate_email,
              controller: widget.usernameController,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre de usuario es requerido';
                }
                if (value.trim().length < 3) {
                  return 'Debe tener al menos 3 caracteres';
                }
                if (value.trim().length > 50) {
                  return 'Debe tener como máximo 50 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomInputField(
              label: "Correo electrónico institucional",
              hintText: "ejemplo@colegio.edu",
              prefixIcon: Icons.mail_outline,
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El email es requerido';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Ingresa un email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomInputField(
              label: "Contraseña",
              hintText: "••••••••",
              prefixIcon: Icons.lock_outline,
              isPassword: !_isPasswordVisible,
              controller: widget.passwordController,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La contraseña es requerida';
                }
                if (value.length < 8) {
                  return 'La contraseña debe tener al menos 8 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomInputField(
              label: "Repetir contraseña",
              hintText: "••••••••",
              prefixIcon: Icons.lock_outline,
              isPassword: !_isConfirmPasswordVisible,
              controller: widget.confirmPasswordController,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                ),
                onPressed: () => setState(() =>
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debes confirmar la contraseña';
                }
                if (value != widget.passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onRegisterTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Crear Cuenta",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("¿Ya tienes cuenta? ",
                    style: TextStyle(color: Colors.grey.shade600)),
                GestureDetector(
                  onTap: widget.onLoginTap,
                  child: const Text(
                    "Inicia sesión",
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}