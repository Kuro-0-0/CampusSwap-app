import 'package:campusswap_app/features/buscador/ui/screens/search_screen.dart';
import 'package:campusswap_app/features/home/ui/widgets/catalogo_anuncios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/categorias/bloc/categoria_bloc.dart';
import 'package:campusswap_app/features/categorias/ui/widgets/category_filter.dart';
import 'package:campusswap_app/features/home/bloc/home_bloc.dart';
import 'package:campusswap_app/features/home/ui/widgets/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()..add(CargarCatalogo())),
        BlocProvider(create: (_) => CategoriaBloc()..add(CargarCategorias())),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            HomeAppBar(
              userName: "Juan",
            ),
            
            Expanded(
              child: Builder(
                builder: (context) {
                  return CatalogoAnunciosWidget(
                    onRetry: () {
                      final categoriaState = context.read<CategoriaBloc>().state;
                      final selectedCategoriaId = categoriaState is CategoriaSuccess 
                          ? categoriaState.selectedCategoriaId : null;
                      context.read<HomeBloc>().add(CargarCatalogo(categoriaId: selectedCategoriaId));
                    },
                    topContent: BlocBuilder<CategoriaBloc, CategoriaState>(
                      builder: (context, categoriaState) {
                        if (categoriaState is CategoriaLoading || categoriaState is CategoriaInitial) {
                          return const SizedBox(
                            height: 40,
                            child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))),
                          );
                        }
                        if (categoriaState is CategoriaError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(child: Text(categoriaState.message, style: const TextStyle(color: Colors.red, fontSize: 12))),
                                TextButton(onPressed: () => context.read<CategoriaBloc>().add(CargarCategorias()), child: const Text('Reintentar')),
                              ],
                            ),
                          );
                        }
                        if (categoriaState is CategoriaSuccess) {
                          return CategoryFilter(
                            categorias: categoriaState.categorias,
                            selectedCategoriaId: categoriaState.selectedCategoriaId,
                            onCategoriaSelected: (newCategory) {
                              context.read<CategoriaBloc>().add(SeleccionarCategoria(categoriaId: newCategory));
                              context.read<HomeBloc>().add(CargarCatalogo(categoriaId: newCategory));
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}