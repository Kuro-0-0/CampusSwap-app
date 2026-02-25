import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileTabToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<String> tabs;

  const ProfileTabToggle({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isLast = entry.key == tabs.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 8.0),
              child: _buildButton(entry.key, entry.value),
            ),
          );
        }).toList(),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}