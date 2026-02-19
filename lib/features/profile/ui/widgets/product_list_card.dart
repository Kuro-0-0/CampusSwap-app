import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';


class ProductListCard extends StatelessWidget {
  final Object item;
  final VoidCallback onTap;
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
        height: 110,
        padding: const EdgeInsets.all(10),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _getImageUrl(),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 90, height: 90, color: Colors.grey[200]),
                  ),
                ),
                if (_getCondition().isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getCondition(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getTitle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _getPriceText(),
                        style: TextStyle(
                          color: _getPriceColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (item is Anuncio)
                    Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      Text("Editar"),
                      SizedBox(width: 12),
                      Icon(
                        Icons.pause_circle_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      Text("Pausar"),
                      SizedBox(width: 12),
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.red[600],
                      ),
                      Text("Eliminar")
                    ],
                  )
                  
                ],
              ),
            ),

            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  String _getImageUrl() {
    if (item is Anuncio) {
      final anuncio = item as Anuncio;
      return anuncio.imagen.isNotEmpty ? anuncio.imagen : '';
    } else if (item is Favorito) {
      final favorito = item as Favorito;
      return favorito.imagen?.isNotEmpty ?? false ? favorito.imagen! : '';
    }
    return '';
  }

  String _getTitle() {
    if (item is Anuncio) {
      return (item as Anuncio).titulo;
    } else if (item is Favorito) {
      return (item as Favorito).tituloAnuncio;
    }
    return '';
  }

  String _getCondition() {
    if (item is Anuncio) {
      return (item as Anuncio).condicion;
    }
    return '';
  }

  String _getPriceText() {
    double? precio;
    if (item is Anuncio) precio = (item as Anuncio).precio;
    if (item is Favorito) precio = (item as Favorito).precio;
    return precio != null ? '\$${precio.toStringAsFixed(2)}' : 'Sin precio';
  }

  Color _getPriceColor() {
    double? precio;
    if (item is Anuncio) precio = (item as Anuncio).precio;
    if (item is Favorito) precio = (item as Favorito).precio;
    return precio != null ? AppColors.primaryBlue : AppColors.successGreen;
  }
}