import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/services/auth_service.dart';
import 'package:campusswap_app/features/auth/ui/screens/login_screen.dart';
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

  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
    _profileBloc.add(LoadProfile());
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>.value(
      value: _profileBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Container(
              height: 280,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
            ),

            SafeArea(
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileUnauthorized) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _profileBloc.add(LoadProfile());
                    });
                  }
                  
                  if (state is FavoritoDeleteSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _profileBloc.add(LoadProfile());
                    });
                  }
                },
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  if (state is ProfileFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error al cargar el perfil',
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              _profileBloc.add(LoadProfile());
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProfileUnauthorized) {
                    return Center(child: CircularProgressIndicator(),);
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
  // Use your existing decoration style inside the icon button
  icon: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.settings, color: Colors.white),
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
            Icon(Icons.logout, color: Colors.black54),
            SizedBox(width: 10),
            Text('Cerrar Sesión'),
          ],
        ),
      ),
    ];
  },
)
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        ProfileInfoCard(usuario: usuario, anunciosCount: misAnuncios.where((a) => a.estado != "CERRADO").length, favoritosCount: misFavoritos.length, ventasCount: misAnuncios.where((a) => a.estado == "CERRADO").length,),

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
                              ? _buildAnunciosList(misAnuncios)
                              : _buildFavoritosList(misFavoritos)
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
      ),
    );
  }

  Widget _buildAnunciosList(List<Anuncio> anuncios) {
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
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final activeAnuncios = anuncios.where((a) => a.estado != "CERRADO").toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      itemCount: activeAnuncios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final anuncio = activeAnuncios[index];
        final isPaused = anuncio.estado == 'PAUSADO';
        
        return ProductListCard(
          item: anuncio,
          onTap: () {
            print("Ir a detalle del anuncio: ${anuncio.id}");
          },
          isPaused: isPaused,
          onEdit: () {
            print("Editar anuncio: ${anuncio.id}");
          },
          onPause: () {
            _showConfirmDialog(
              title: isPaused ? 'Reactivar Anuncio' : 'Pausar Anuncio',
              message: isPaused 
                ? '¿Deseas reactivar este anuncio?'
                : '¿Deseas pausar este anuncio temporalmente?',
              onConfirm: () {
                if (isPaused) {
                  _profileBloc.add(ReactivateAnuncio(anuncioId: anuncio.id));
                } else {
                  _profileBloc.add(PauseAnuncio(anuncioId: anuncio.id));
                }
              },
            );
          },
          onDelete: () {
            _showConfirmDialog(
              title: 'Eliminar Anuncio',
              message: '¿Estás seguro que deseas eliminar este anuncio? Esta acción no se puede deshacer.',
              isDestructive: true,
              onConfirm: () {
                _profileBloc.add(DeleteAnuncio(anuncioId: anuncio.id));
              },
            );
          },
        );
      },
    );
  }

  

  Widget _buildFavoritosList(List<Favorito> favoritos) {
    if (favoritos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes anuncios favoritos',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      itemCount: favoritos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final favorito = favoritos[index];

        return ProductListCard(
          item: favorito,
          onTap: () {
            print("Ir a detalle de favorito: ${favorito.tituloAnuncio}");
          },
          onFavoritesDelete: () {
            _showConfirmDialog(
              title: 'Eliminar Favorito',
              message: '¿Deseas eliminar este anuncio de tus favoritos?',
              isDestructive: true,
              onConfirm: () {
                _profileBloc.add(DeleteFavorito(favoritoId: favorito.id));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
}
