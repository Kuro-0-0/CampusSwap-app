import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileTabToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const ProfileTabToggle({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildButton(0, "Mis Anuncios")),
          const SizedBox(width: 16),
          Expanded(child: _buildButton(1, "Favoritos")),
        ],
      ),
    );
  }

  Widget _buildButton(int index, String text) {
    final isSelected = selectedIndex == index;
    return ElevatedButton(
      onPressed: () => onTabChanged(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryBlue : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppColors.textDark,
        elevation: isSelected ? 2 : 0,
        side: isSelected ? null : BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}