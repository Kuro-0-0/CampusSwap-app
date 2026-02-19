import 'package:campusswap_app/core/models/categoria_response_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryFilter extends StatelessWidget {
  final List<CategoriaResponseModel> categorias;
  final int? selectedCategoriaId;
  final ValueChanged<int?> onCategoriaSelected;

  const CategoryFilter({
    super.key,
    required this.categorias,
    required this.selectedCategoriaId,
    required this.onCategoriaSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categoriasConTodos = <CategoriaResponseModel?>[null, ...categorias];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categoriasConTodos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final categoria = categoriasConTodos[index];
          final isTodos = categoria == null;
          final isSelected = isTodos
              ? selectedCategoriaId == null
              : categoria.id == selectedCategoriaId;

          return GestureDetector(
            onTap: () => onCategoriaSelected(isTodos ? null : categoria.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  isTodos ? 'Todos' : categoria.nombre,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
