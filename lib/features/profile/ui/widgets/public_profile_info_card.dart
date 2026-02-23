import 'package:campusswap_app/core/models/usuario_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PublicProfileInfoCard extends StatelessWidget {
  final UsuarioResponse usuario;
  final int anunciosCount;
  final int ventasCount;

  const PublicProfileInfoCard({
    super.key,
    required this.usuario,
    required this.anunciosCount,
    required this.ventasCount,
  });

   String get _imageUrl {
    if (usuario.imageUrl.isEmpty)
      return 'https://via.placeholder.com/400x350.png?text=Sin+Imagen';

    if (usuario.imageUrl.startsWith('http')) return usuario.imageUrl;
    return '${TokenStorage.baseUrl}/api/v1/imagen/${usuario.imageUrl}';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(usuario.fechaRegistro);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(
                  _imageUrl,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario.email,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (usuario.reputacionMedia != null) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            usuario.reputacionMedia!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warningOrange,
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.star_border, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            "Sin valoraciones",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          "Desde $formattedDate",
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(anunciosCount.toString(), "Anuncios"),
              _buildStatItem(ventasCount.toString(), "Ventas"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }
}
