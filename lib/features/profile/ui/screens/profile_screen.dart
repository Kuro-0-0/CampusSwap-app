import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/favorito_response_model.dart';
import 'package:campusswap_app/core/models/usuario_response_model.dart';
import 'package:campusswap_app/features/profile/ui/widgets/product_list_card.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_tab_toggle.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0; // 0: Mis Anuncios, 1: Favoritos

  late UsuarioResponse usuario; // Desde baseUrl /api/v1/usuarios

  final List<Anuncio> misAnuncios  = []; // Desde baseUrl /api/v1/anuncios/{usuario.id}

  final List<Favorito> misFavoritos = []; // Desde baseUrl /api/v1/favoritos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 280, // Altura del fondo azul
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),

          SafeArea(
            child: Column(
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Tarjeta Flotante (Widget extraído)
                const ProfileInfoCard(),

                const SizedBox(height: 24),

                // Toggle Buttons (Mis Anuncios / Favoritos)
                ProfileTabToggle(
                  selectedIndex: _selectedTab,
                  onTabChanged: (index) {
                    setState(() => _selectedTab = index);
                  },
                ),

                const SizedBox(height: 16),

                // Lista Dinámica
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: _selectedTab == 0
                        ? misAnuncios.length
                        : misFavoritos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (_selectedTab == 0) {
                        // Caso A: Mis Anuncios
                        return ProductListCard(
                          item: misAnuncios[index],
                          onTap: () {
                            print("Ir a detalle del anuncio");
                          },
                        );
                      } else {
                        // Caso B: Favoritos
                        // Aquí reutilizamos tu ProductListCard del Core o creamos uno similar
                        // con el corazón rojo a la derecha.
                        // Para ajustarnos EXACTAMENTE al diseño, usaremos un widget simple aquí:
                        // En el itemBuilder cuando _selectedTab == 1 (Favoritos)
                        return ProductListCard(
                          item: misFavoritos[index],
                          onTap: () {
                            print("Ir a detalle de favorito");
                          },
                          // Aquí aprovechamos la propiedad 'trailing' que añadí para poner el corazón
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () {
                              // Lógica para quitar de favoritos
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
