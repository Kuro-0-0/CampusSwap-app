import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/models/valoracion_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:campusswap_app/features/anuncio_detail/ui/screens/anuncio_detail_screen.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:campusswap_app/features/profile/bloc/public_profile_bloc.dart';
import 'package:campusswap_app/features/profile/ui/widgets/product_list_card.dart';
import 'package:campusswap_app/features/profile/ui/widgets/profile_tab_toggle.dart';
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
  int _selectedTab = 0;

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
                if (state is PublicProfileIsOwnProfile) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Este es tu perfil. Usa la pestaña Perfil para verlo.'),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                } else if (state is PublicProfileFailure) {
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
                  final myFavoritos = state.myFavoritos;
                  final valoraciones = state.valoraciones;

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
                        ventasCount: anuncios
                            .where((a) => a.estado == "CERRADO")
                            .length,
                      ),
                      const SizedBox(height: 24),
                      
                      ProfileTabToggle(
                        tabs: const ["Anuncios", "Valoraciones"],
                        selectedIndex: _selectedTab,
                        onTabChanged: (index) {
                          setState(() => _selectedTab = index);
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: _selectedTab == 0
                            ? _buildAnunciosList(context, anuncios, myFavoritos)
                            : _buildValoracionesList(context, valoraciones),
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

  Widget _buildAnunciosList(
    BuildContext context,
    List<Anuncio> anuncios,
    List<Favorito> myFavoritos,
  ) {
    final activeAnuncios = anuncios.where((a) => a.estado != "CERRADO").toList();

    if (activeAnuncios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Este usuario no tiene anuncios activos',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: activeAnuncios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final anuncio = activeAnuncios[index];

        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            bool isFav = false;
            int? favoritoId;

            if (profileState is ProfileLoaded) {
              final fav = profileState.favoritos.where((f) => f.anuncio.id == anuncio.id).firstOrNull;
              isFav = fav != null;
              favoritoId = fav?.id;
            } else {
              final fav = myFavoritos.where((f) => f.anuncio.id == anuncio.id).firstOrNull;
              isFav = fav != null;
              favoritoId = fav?.id;
            }

            return ProductListCard(
              item: anuncio,
              trailing: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  if (isFav && favoritoId != null) {
                    context.read<ProfileBloc>().add(DeleteFavorito(favoritoId: favoritoId));
                  } else {
                    context.read<ProfileBloc>().add(AddFavorito(anuncioId: anuncio.id));
                  }
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: context.read<PublicProfileBloc>()),
                        BlocProvider.value(value: context.read<ProfileBloc>()),
                      ],
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
      },
    );
  }

  Widget _buildValoracionesList(BuildContext context, List<Valoracion> valoraciones) {
    if (valoraciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Este usuario aún no tiene valoraciones',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: valoraciones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final val = valoraciones[index];
        
        final imageUrl = val.fotoPerfilEvaluador != null && val.fotoPerfilEvaluador!.isNotEmpty
            ? '${TokenStorage.baseUrl}/api/v1/imagen/${val.fotoPerfilEvaluador}'
            : null;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                      child: imageUrl == null ? const Icon(Icons.person, color: AppColors.primaryBlue) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(val.evaluadorNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(val.fecha, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < val.puntuacion.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(val.comentario, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  'Sobre: ${val.anuncioTitulo}',
                  style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}