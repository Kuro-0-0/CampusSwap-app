import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MyAdTile extends StatelessWidget {
  final Anuncio product;

  const MyAdTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.imagen,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Info y Acciones
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.precio != null ? '\$${product.precio}' : 'Sin precio',
                  style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Botones de acción
                Row(
                  children: [
                    _buildAction(Icons.edit_outlined, "Editar"),
                    const SizedBox(width: 16),
                    _buildAction(Icons.pause_circle_outline, "Pausar"),
                    const SizedBox(width: 16),
                    _buildAction(Icons.delete_outline, "Eliminar", isDestructive: true),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, {bool isDestructive = false}) {
    return InkWell(
      onTap: () {}, // TODO: Callbacks
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDestructive ? Colors.red : Colors.grey),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDestructive ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}