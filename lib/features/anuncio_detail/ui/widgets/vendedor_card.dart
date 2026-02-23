import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:campusswap_app/features/profile/bloc/public_profile_bloc.dart';
import 'package:campusswap_app/features/profile/ui/screens/public_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class VendedorCard extends StatelessWidget {
  final String name;
  final String date;
  final double? rating;
  final String? usuarioId;
  final String imagen;

  const VendedorCard({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    required this.usuarioId,
    required this.imagen
  });

  String get _imageUrl {
    if (imagen.isEmpty)
      return 'https://via.placeholder.com/400x350.png?text=Sin+Imagen';

    if (imagen.startsWith('http')) return imagen;
    return '${TokenStorage.baseUrl}/api/v1/imagen/${imagen}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: usuarioId != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => PublicProfileBloc()),
                      BlocProvider.value(value: context.read<ProfileBloc>()),
                    ],
                    child: PublicProfileScreen(usuarioId: usuarioId!),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade500.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(_imageUrl),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      if (rating != null) const Icon(Icons.star, size: 16, color: Colors.amber),
                      if (rating != null) const SizedBox(width: 4),
                    ],
                  ),
                  Text(
                    rating == null ? "Sin valoraciones" : rating.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
