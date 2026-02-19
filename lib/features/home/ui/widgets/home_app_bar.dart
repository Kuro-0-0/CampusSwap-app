import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;
  final VoidCallback onSearchTap;

  const HomeAppBar({
    super.key,
    required this.userName,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo
          Row(
            children: [
              Text(
                "Hola, ",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18),
              ),
              Text(
                "$userName 👋",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Barra de Búsqueda (Fake)
          GestureDetector(
            onTap: onSearchTap, // TODO: Trigger navigation to Search Feature
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Buscar libros, uniformes, material...",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}