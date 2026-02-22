import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/services/anuncio_service.dart';
import 'package:campusswap_app/features/anuncio_detail/ui/screens/anuncio_detail_screen.dart';
import 'package:campusswap_app/features/profile/bloc/public_profile_bloc.dart';
import 'package:campusswap_app/features/profile/ui/widgets/product_list_card.dart';
import 'package:campusswap_app/features/profile/ui/widgets/public_profile_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class PublicProfileScreen extends StatefulWidget {
  final String usuarioId;

  const PublicProfileScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PublicProfileBloc>().add(LoadPublicProfile(usuarioId: widget.usuarioId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
          ),
          SafeArea(
            child: BlocConsumer<PublicProfileBloc, PublicProfileState>(
              listener: (context, state) {
                if (state is PublicProfileFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is PublicProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (state is PublicProfileFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<PublicProfileBloc>().add(
                              LoadPublicProfile(usuarioId: widget.usuarioId),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PublicProfileLoaded) {
                  final usuario = state.usuario;
                  final anuncios = state.anuncios;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              usuario.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      PublicProfileInfoCard(
                        usuario: usuario,
                        anunciosCount: anuncios
                            .where((a) => a.estado != "CERRADO")
                            .length,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _buildAnunciosList(context, anuncios),
                      ),
                    ],
                  );
                }

                return const SizedBox.expand();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnunciosList(BuildContext context, List<Anuncio> anuncios) {
    if (anuncios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Este usuario no tiene anuncios publicados',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final activeAnuncios = anuncios
        .where((a) => a.estado != "CERRADO")
        .toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: activeAnuncios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final anuncio = activeAnuncios[index];

        return ProductListCard(
          item: anuncio,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => BlocProvider.value(
                  value: context.read<PublicProfileBloc>(),
                  child: AnuncioDetailScreen(
                    anuncio: anuncio,
                    isMine: false,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
