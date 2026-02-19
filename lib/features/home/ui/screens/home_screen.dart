import 'package:campusswap_app/features/auth/ui/screens/login_screen.dart';
import 'package:campusswap_app/features/home/bloc/home_bloc.dart';
import 'package:campusswap_app/features/home/ui/widgets/anuncio_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/category_filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = "Todos";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(CargarCatalogo()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            HomeAppBar(
              userName: "Juan",
              onSearchTap: () {
                print("Navegar a búsqueda");
              },
            ),

            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    );
                  }

                  if (state is HomeError) {
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Iniciar Sesión'),
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

                  if (state is HomeSuccess) {
                    final anuncios = state.catalogo.content;
                    
                    if (anuncios.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay anuncios disponibles',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.only(top: 24, bottom: 100),
                      children: [
                        CategoryFilter(
                          categories: const [
                            "Todos",
                            "Libros",
                            "Uniformes",
                            "Tecnología",
                          ],
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (newCategory) {
                            setState(() => _selectedCategory = newCategory);
                          },
                        ),

                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Anuncios recientes",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                "${anuncios.length} anuncios",
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: anuncios.length,
                          itemBuilder: (context, index) {
                            return AnuncioCard(
                              anuncio: anuncios[index],
                              onTap: () {
                                print("Abrir producto: ${anuncios[index].titulo}");
                              },
                            );
                          },
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
