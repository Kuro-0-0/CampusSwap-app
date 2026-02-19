import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';


class ProductListCard extends StatelessWidget {
  final Object item;
  final VoidCallback onTap;
  // Opcional: Para mostrar un icono de acción a la derecha (ej: Corazón o Basura)
  final Widget? trailing; 

  const ProductListCard({
    super.key,
    required this.item,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110, // Altura fija para consistencia en listas
        padding: const EdgeInsets.all(10), // Padding interno
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Imagen a la izquierda (Cuadrada o rectangular)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    // Si es Anuncio mostramos la imagen, si es Favorito mostramos un placeholder
                    item is Anuncio && (item as Anuncio).imagen.isNotEmpty
                        ? (item as Anuncio).imagen
                        : '',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 90, height: 90, color: Colors.grey[200]),
                  ),
                ),
                // Badge de estado (Nuevo/Usado)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      // Mostrar condición si viene de Anuncio
                      (item is Anuncio ? (item as Anuncio).condicion : "").toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),

            // 2. Información Central
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // Título según tipo
                    item is Anuncio
                        ? (item as Anuncio).titulo
                        : (item is Favorito ? (item as Favorito).tituloAnuncio : ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Precio y Rating
                  Row(
                    children: [
                      Text(
                        // Precio según tipo
                        () {
                          double? precio;
                          if (item is Anuncio) precio = (item as Anuncio).precio;
                          if (item is Favorito) precio = (item as Favorito).precio;
                          return precio != null ? '\$${precio}' : 'Sin precio';
                        }(),
                        style: TextStyle(
                          color: () {
                            double? precio;
                            if (item is Anuncio) precio = (item as Anuncio).precio;
                            if (item is Favorito) precio = (item as Favorito).precio;
                            return precio != null ? AppColors.primaryBlue : AppColors.successGreen;
                          }(),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      if (trailing == null) ...[
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          10.toString(), // MODIFICAR POR EL RATING DEL USUARIO
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),

            // 3. Widget opcional a la derecha (ej: Corazón de favoritos)
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}