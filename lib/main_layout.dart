import 'package:campusswap_app/features/home/ui/screens/home_screen.dart';
import 'package:campusswap_app/features/messages/bloc/mensaje_bloc.dart';
import 'package:campusswap_app/features/messages/ui/screens/messages_screen.dart';
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const MessagesScreen(),
    const ProfileScreen()
  ];

  void _onTabTapped(int index, BuildContext innerContext) {
    setState(() {
      _currentIndex = index;
    });

    if(index == 2){
      innerContext.read<MensajeBloc>().add(GetChats());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()..add(CargarCatalogo())),
        BlocProvider(create: (_) => CategoriaBloc()..add(CargarCategorias())),
        BlocProvider(create: (_) => ProfileBloc()..add(LoadProfile())),
        BlocProvider(create: (_) => MensajeBloc()..add(GetChats())),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: AppColors.background,
            
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),

            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  innerContext,
                  MaterialPageRoute(builder: (context) => const AnuncioFormScreen()),
                ).then((creadoConExito) {
                  if (creadoConExito == true) {
                    innerContext.read<HomeBloc>().add(CargarCatalogo());
                    innerContext.read<ProfileBloc>().add(LoadProfile());
                  }
                });
              },
              backgroundColor: AppColors.primaryBlue,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
            
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              color: Colors.white,
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(innerContext, icon: Icons.home, index: 0, label: "Inicio"),
                    _buildNavItem(innerContext, icon: Icons.search, index: 1, label: "Buscar"),
                    const SizedBox(width: 48),
                    _buildNavItem(innerContext, icon: Icons.chat_bubble_outline, index: 2, label: "Mensajes"),
                    _buildNavItem(innerContext, icon: Icons.person_outline, index: 3, label: "Perfil"),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildNavItem(BuildContext innerContext, {required IconData icon, required int index, required String label}) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index, innerContext),
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
            )
          ],
        ),
      ),
    );
  }
}