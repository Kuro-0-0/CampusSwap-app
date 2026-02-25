import 'dart:async';

import 'package:campusswap_app/core/services/purchase_event_service.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:campusswap_app/features/auth/bloc/auth_bloc.dart';
import 'package:campusswap_app/features/auth/ui/screens/login_screen.dart';
import 'package:campusswap_app/features/home/ui/screens/home_screen.dart';
import 'package:campusswap_app/features/messages/bloc/mensaje_bloc.dart';
import 'package:campusswap_app/features/messages/ui/screens/messages_screen.dart';
import 'package:campusswap_app/features/panel_admin/bloc/panel_admin_bloc.dart';
import 'package:campusswap_app/features/panel_admin/ui/screens/panel_admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/buscador/ui/screens/search_screen.dart';
import 'package:campusswap_app/features/profile/ui/screens/profile_screen.dart';
import 'package:campusswap_app/features/anuncio_form/ui/screens/anuncio_form_screen.dart';

import 'package:campusswap_app/features/home/bloc/home_bloc.dart';
import 'package:campusswap_app/features/categorias/bloc/categoria_bloc.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final HomeBloc _homeBloc;
  late final CategoriaBloc _categoriaBloc;
  late final ProfileBloc _profileBloc;
  late final MensajeBloc _mensajeBloc;
  late final StreamSubscription<int> _purchaseSub;

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc()..add(CargarCatalogo());
    _categoriaBloc = CategoriaBloc()..add(CargarCategorias());
    _profileBloc = ProfileBloc();
    _mensajeBloc = MensajeBloc();

    _comprobarSesion();

    _purchaseSub = PurchaseEventBus.instance.onPurchase.listen((_) {
      _homeBloc.add(CargarCatalogo());
      _profileBloc.add(LoadProfile());
      _mensajeBloc.add(GetChats());
    });
  }

  @override
  void dispose() {
    _purchaseSub.cancel();
    _homeBloc.close();
    _categoriaBloc.close();
    _profileBloc.close();
    _mensajeBloc.close();
    super.dispose();
  }

  void _requerirLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Debes iniciar sesión para usar esta función."),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onTabTapped(int index, BuildContext innerContext, bool isAdmin, bool isGuest) {
    setState(() {
      _currentIndex = index;
    });

    if (!isAdmin && index == 2) {
      _mensajeBloc.add(GetChats());
    }

    if (isGuest && (index == 2 || index == 3)) {
      _requerirLogin(innerContext);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _categoriaBloc),
        BlocProvider.value(value: _profileBloc),
        BlocProvider.value(value: _mensajeBloc),
        BlocProvider(create: (_) => PanelAdminBloc()..add(CargarEstadisticas())),
      ],
      child: Builder(
        builder: (innerContext) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              bool isAdmin = false;
              bool isGuest = true;
              if (profileState is ProfileLoaded) {
                isGuest = false;
                isAdmin = profileState.usuario.roles.any(
                  (rol) => rol.toUpperCase().contains('ADMIN'),
                );
              }

              final List<Widget> activeScreens = isAdmin
                  ? [
                      const HomeScreen(),
                      const SearchScreen(),
                      const AdminPanelScreen(),
                    ]
                  : [
                      const HomeScreen(),
                      const SearchScreen(),
                      const MessagesScreen(),
                      const ProfileScreen(),
                    ];

              final safeIndex = _currentIndex >= activeScreens.length
                  ? 0
                  : _currentIndex;

              return BlocListener<AuthBloc, AuthState>(
                listener: (context, authState) {
                  if (authState is Unauthenticated) {
                    
                    if (authState.forced) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tu sesión ha expirado. Por favor, inicia sesión de nuevo."),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Scaffold(
                  backgroundColor: AppColors.background,

                  body: IndexedStack(index: safeIndex, children: activeScreens),

                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: isAdmin
                      ? null
                      : FloatingActionButton(
                          onPressed: () {
                            if (isGuest) {
                              _requerirLogin(innerContext);
                              return;
                            }

                            Navigator.push(
                              innerContext,
                              MaterialPageRoute(
                                builder: (context) => const AnuncioFormScreen(),
                              ),
                            ).then((creadoConExito) {
                              if (creadoConExito == true) {
                                innerContext.read<HomeBloc>().add(
                                  CargarCatalogo(),
                                );
                                innerContext.read<ProfileBloc>().add(
                                  LoadProfile(),
                                );
                              }
                            });
                          },
                          backgroundColor: AppColors.primaryBlue,
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                  bottomNavigationBar: BottomAppBar(
                    shape: const CircularNotchedRectangle(),
                    notchMargin: 8,
                    color: Colors.white,
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: isAdmin
                            ? MainAxisAlignment.spaceAround
                            : MainAxisAlignment.spaceBetween,
                        children: isAdmin
                            ? [
                                _buildNavItem(
                                  innerContext,
                                  icon: Icons.home,
                                  index: 0,
                                  label: "Inicio",
                                  isAdmin: isAdmin,
                                  isGuest: isGuest,
                                ),
                                _buildNavItem(
                                  innerContext,
                                  icon: Icons.search,
                                  index: 1,
                                  label: "Buscar",
                                  isAdmin: isAdmin,
                                  isGuest: isGuest,
                                ),
                                _buildNavItem(
                                  innerContext,
                                  icon: Icons.admin_panel_settings,
                                  index: 2,
                                  label: "Admin",
                                  isAdmin: isAdmin,
                                  isGuest: isGuest,
                                ),
                              ]
                            : [
                                _buildNavItem(
                                  innerContext,
                                  icon: Icons.home,
                                  index: 0,
                                  label: "Inicio",
                                  isAdmin: isAdmin,
                                  isGuest: isGuest,
                                ),
                                _buildNavItem(
                                  innerContext,
                                  icon: Icons.search,
                                  index: 1,
                                  label: "Buscar",
                                  isAdmin: isAdmin,
                                  isGuest: isGuest,
                                ),
                                const SizedBox(width: 48),
                                _buildNavItem(
                                  innerContext,
                                  icon: Icons.chat_bubble_outline,
                                  index: 2,
                                  label: "Mensajes",
                                  isAdmin: isAdmin,
                                  isGuest: isGuest,
                                ),
                                _buildNavItem(
                                  innerContext,
                                  icon: Icons.person_outline,
                                  index: 3,
                                  label: "Perfil",
                                  isAdmin: isAdmin,
                                  isGuest: isGuest,
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext innerContext, {
    required IconData icon,
    required int index,
    required String label,
    required bool isAdmin,
    required bool isGuest,
  }) {
    final safeIndex = _currentIndex >= (isAdmin ? 3 : 4) ? 0 : _currentIndex;
    final isSelected = safeIndex == index;

    return InkWell(
      onTap: () => _onTabTapped(index, innerContext, isAdmin, isGuest),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
              size: 26,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _comprobarSesion() async {
  final token = await TokenStorage().getToken();
  if (token != null && token.isNotEmpty) {
    _profileBloc.add(LoadProfile());
    _mensajeBloc.add(GetChats());
  }
}
}


