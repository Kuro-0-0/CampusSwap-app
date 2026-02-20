import 'package:campusswap_app/features/anuncio_form/ui/screens/anuncio_form_screen.dart';
import 'package:campusswap_app/features/buscador/ui/screens/search_screen.dart';
import 'package:campusswap_app/features/home/ui/screens/home_screen.dart';
import 'package:campusswap_app/features/profile/ui/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';

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
    const Center(child: Text("Pantalla chats"),),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              context,
              MaterialPageRoute(builder: (context) => const AnuncioFormScreen()),
            );
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
              _buildNavItem(icon: Icons.home, index: 0, label: "Inicio"),
              _buildNavItem(icon: Icons.search, index: 1, label: "Buscar"),
              const SizedBox(width: 48),
              _buildNavItem(icon: Icons.chat_bubble_outline, index: 2, label: "Msjes"),
              _buildNavItem(icon: Icons.person_outline, index: 3, label: "Perfil"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index, required String label}) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
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