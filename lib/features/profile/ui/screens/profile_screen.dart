import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/services/anuncio_service.dart';
import 'package:campusswap_app/core/services/auth_service.dart';
import 'package:campusswap_app/features/anuncio_detail/ui/screens/anuncio_detail_screen.dart';
import 'package:campusswap_app/features/anuncio_form/ui/screens/anuncio_form_screen.dart';
import 'package:campusswap_app/features/auth/ui/screens/login_screen.dart';
import 'package:campusswap_app/features/home/bloc/home_bloc.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:campusswap_app/features/profile/ui/widgets/product_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_tab_toggle.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

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
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileUnauthorized) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }

                if (state is AnuncioActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  context.read<HomeBloc>().add(CargarCatalogo());
                  context.read<ProfileBloc>().add(LoadProfile());
                }

                if (state is FavoritoDeleteSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  context.read<ProfileBloc>().add(LoadProfile());
                }

                if (state is ProfileFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (state is ProfileFailure) {
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
                          onPressed: () => context.read<ProfileBloc>().add(LoadProfile()),
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

                if (state is ProfileUnauthorized) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProfileLoaded) {
                  final usuario = state.usuario;
                  final misAnuncios = state.anuncios;
                  final misFavoritos = state.favoritos;

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
                            const Text(
                              "Perfil",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                              ),
                              onSelected: (value) async {
                                if (value == 'logout') {
                                  await _handleLogout(context);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem<String>(
                                    value: 'logout',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Cerrar Sesión'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      ProfileInfoCard(
                        usuario: usuario,
                        anunciosCount: misAnuncios
                            .where((a) => a.estado != "CERRADO")
                            .length,
                        favoritosCount: misFavoritos.length,
                        ventasCount: misAnuncios
                            .where((a) => a.estado == "CERRADO")
                            .length,
                      ),

                      const SizedBox(height: 24),

                      ProfileTabToggle(
                        selectedIndex: _selectedTab,
                        onTabChanged: (index) {
                          setState(() => _selectedTab = index);
                        },
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: _selectedTab == 0
                            ? _buildAnunciosList(context, misAnuncios)
                            : _buildFavoritosList(context, misFavoritos),
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
              'No tienes anuncios publicados',
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
        final isPaused = anuncio.estado == 'PAUSADO';

        return ProductListCard(
          item: anuncio,
         onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => BlocProvider.value(
                  value: context.read<ProfileBloc>(),
                  child: AnuncioDetailScreen(
                    anuncio: anuncio,
                    isMine: true, 
                  ),
                ),
              ),
            ).then((resultado) {
              if (resultado == 'recargar') {
                context.read<HomeBloc>().add(CargarCatalogo());
                context.read<ProfileBloc>().add(LoadProfile());
              } else if (resultado == 'pausar') {
                context.read<ProfileBloc>().add(PauseAnuncio(anuncioId: anuncio.id));
              } else if (resultado == 'reactivar') {
                context.read<ProfileBloc>().add(ReactivateAnuncio(anuncioId: anuncio.id));
              } else if (resultado == 'eliminar') {
                context.read<ProfileBloc>().add(DeleteAnuncio(anuncioId: anuncio.id));
              }
            });
          },
          isPaused: isPaused,
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AnuncioFormScreen(anuncioAEditar: anuncio),
              ),
            ).then((editadoConExito) {
              if (editadoConExito == true) {
                context.read<HomeBloc>().add(CargarCatalogo());
                context.read<ProfileBloc>().add(LoadProfile());
              }
            });
          },
          onPause: () {
            _showConfirmDialog(
              title: isPaused ? 'Reactivar Anuncio' : 'Pausar Anuncio',
              message: isPaused
                  ? '¿Deseas reactivar este anuncio?'
                  : '¿Deseas pausar este anuncio temporalmente?',
              onConfirm: () {
                if (isPaused) {
                  context.read<ProfileBloc>().add(ReactivateAnuncio(anuncioId: anuncio.id));
                } else {
                  context.read<ProfileBloc>().add(PauseAnuncio(anuncioId: anuncio.id));
                }
              },
            );
          },
          onDelete: () {
            _showConfirmDialog(
              title: 'Eliminar Anuncio',
              message:
                  '¿Estás seguro que deseas eliminar este anuncio? Esta acción no se puede deshacer.',
              isDestructive: true,
              onConfirm: () {
                context.read<ProfileBloc>().add(DeleteAnuncio(anuncioId: anuncio.id));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritosList(BuildContext context, List<Favorito> favoritos) {
    if (favoritos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes anuncios favoritos',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: favoritos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final favorito = favoritos[index];

        return ProductListCard(
          item: favorito,
        onTap: () async {
            _showLoadingDialog(context);
            try {
              final anuncioService = AnuncioService();
              final anuncioCompleto = await anuncioService.getAnuncioById(favorito.anuncio.id);
              
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => BlocProvider.value(
                      value: context.read<ProfileBloc>(),
                      child: AnuncioDetailScreen(
                        anuncio: anuncioCompleto,
                      ),
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cargar el anuncio: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          onFavoritesDelete: () {
            _showConfirmDialog(
              title: 'Eliminar Favorito',
              message: '¿Deseas eliminar este anuncio de tus favoritos?',
              isDestructive: true,
              onConfirm: () {
                context.read<ProfileBloc>().add(DeleteFavorito(favoritoId: favorito.id));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();

    try {
      await authService.logout();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Confirmar',
              style: TextStyle(
                color: isDestructive ? Colors.red : AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}