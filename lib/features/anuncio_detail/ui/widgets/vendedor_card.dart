import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:campusswap_app/features/profile/bloc/public_profile_bloc.dart';
import 'package:campusswap_app/features/profile/ui/screens/public_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class VendedorCard extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String? usuarioId;

  const VendedorCard({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    this.usuarioId,
  });

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
            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage("https://via.placeholder.com/150"),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  )
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