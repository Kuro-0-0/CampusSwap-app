// features/chat/ui/widgets/chat_product_header.dart

import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/services/anuncio_service.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:campusswap_app/core/services/valoracion_service.dart';
import 'package:campusswap_app/features/anuncio_detail/ui/screens/anuncio_detail_screen.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:campusswap_app/features/valoracion/bloc/valoracion_bloc.dart';
import 'package:campusswap_app/features/valoracion/ui/widgets/rating_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class ChatProductHeader extends StatefulWidget {
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

  @override
  State<ChatProductHeader> createState() => _ChatProductHeaderState();
}

class _ChatProductHeaderState extends State<ChatProductHeader> {
  bool _hasAlreadyRated = false;
  bool _isCheckingRating = false;
  bool _isComprador = false;
  bool _isCheckingComprador = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyRated();
    _checkIfComprador();
  }

  @override
  void didUpdateWidget(ChatProductHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check buyer/rating status when the anuncio estado changes (e.g. after purchase)
    if (oldWidget.anuncio.estado != widget.anuncio.estado) {
      _checkIfComprador();
      _checkIfAlreadyRated();
    }
  }

  Future<void> _checkIfAlreadyRated() async {
    setState(() => _isCheckingRating = true);
    try {
      final hasRated = await ValoracionService().haValorizado(widget.anuncio.id);
      if (mounted) {
        setState(() => _hasAlreadyRated = hasRated);
      }
    } catch (e) {
      // If there's an error, assume they haven't rated
      if (mounted) {
        setState(() => _hasAlreadyRated = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingRating = false);
      }
    } 
  }

  Future<void> _checkIfComprador() async {
    setState(() => _isCheckingComprador = true);
    try {
      final isComprador = await AnuncioService().comprobarComprador(widget.anuncio.id);
      if (mounted) {
        setState(() => _isComprador = isComprador);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isComprador = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingComprador = false);
      }
    }
  }
  
  String get _imageUrl {
    if (widget.imagenAnuncio.isEmpty)
      return 'https://via.placeholder.com/400x350.png?text=Sin+Imagen';

    if (widget.imagenAnuncio.startsWith('http')) return widget.imagenAnuncio;
    
    return '${TokenStorage.baseUrl}/api/v1/imagen/${widget.imagenAnuncio}';
  }

  Future<void> _verAnuncio(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final anuncioCompleto = await AnuncioService().getAnuncioById(widget.anuncio.id);

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
        child: RatingModal(
          anuncio: widget.anuncio,
          hasAlreadyRated: _hasAlreadyRated,
        ),
      ),
    ).then((result) {
      // If valoración was successfully created, update the state
      if (result == true && mounted) {
        setState(() => _hasAlreadyRated = true);
      }
    });
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
                      widget.tituloAnuncio,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.anuncio.precio == 0.0 || widget.anuncio.precio == null ? "Consultar condiciones" : "${widget.anuncio.precio?.toStringAsFixed(2)} €",
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
          if (!widget.isOwner) ...[
            if (widget.anuncio.estado != 'CERRADO') ...[  
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onBuyTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Comprar",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ] else if (_isCheckingComprador) ...[  
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ] else if (_isComprador) ...[  
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasAlreadyRated ? null : () => _showRatingModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasAlreadyRated ? Colors.grey : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _hasAlreadyRated ? "Ya valorado" : "Valorar",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
