// features/chat/ui/widgets/chat_product_header.dart

import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/services/anuncio_service.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:campusswap_app/features/anuncio_detail/ui/screens/anuncio_detail_screen.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:campusswap_app/features/valoracion/bloc/valoracion_bloc.dart';
import 'package:campusswap_app/features/valoracion/ui/widgets/rating_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class ChatProductHeader extends StatelessWidget {
  final String tituloAnuncio;
  final String imagenAnuncio;
  final Anuncio anuncio;
  final VoidCallback onBuyTap;
  final bool isOwner;

  const ChatProductHeader({
    super.key,
    required this.tituloAnuncio,
    required this.imagenAnuncio,
    required this.anuncio,
    required this.onBuyTap,
    this.isOwner = false,
  });
  
  String get _imageUrl {
    if (imagenAnuncio.isEmpty)
      return 'https://via.placeholder.com/400x350.png?text=Sin+Imagen';

    if (imagenAnuncio.startsWith('http')) return imagenAnuncio;
    
    return '${TokenStorage.baseUrl}/api/v1/imagen/$imagenAnuncio';
  }

  Future<void> _verAnuncio(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final anuncioCompleto = await AnuncioService().getAnuncioById(anuncio.id);

      if (context.mounted) {
        Navigator.pop(context); 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => ProfileBloc()..add(LoadProfile()),
              child: AnuncioDetailScreen(
                anuncio: anuncioCompleto,
                isMine: false,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar el anuncio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRatingModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => ValoracionBloc(),
        child: RatingModal(anuncio: anuncio),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tituloAnuncio,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      anuncio.precio == 0.0 || anuncio.precio == null ? "Consultar condiciones" : "${anuncio.precio?.toStringAsFixed(2)} €",
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _verAnuncio(context),
                      child: const Text(
                        "Ver anuncio",
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isOwner) ...[  
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: anuncio.estado == 'CERRADO' 
                    ? () => _showRatingModal(context)
                    : onBuyTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: anuncio.estado == 'CERRADO' ? Colors.green : AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  anuncio.estado == 'CERRADO' ? "Valorar" : "Comprar",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
