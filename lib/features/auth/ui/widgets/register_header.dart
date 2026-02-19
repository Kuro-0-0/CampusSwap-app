import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  final VoidCallback onBackTap;

  const RegisterHeader({super.key, required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 20), // Margen superior SafeArea
          
          const SizedBox(height: 10),
          
          // Icono del libro
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Color(0xFF1976D2), size: 32),
          ),
          
          const SizedBox(height: 16),
          
          // Títulos
          const Text(
            "Crear cuenta",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Únete a la comunidad CampusSwap",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}