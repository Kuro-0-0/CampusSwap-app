import 'package:campusswap_app/features/categorias/bloc/categoria_bloc.dart';
import 'package:campusswap_app/features/categorias/ui/widgets/category_filter.dart';
import 'package:campusswap_app/features/home/bloc/home_bloc.dart';
import 'package:campusswap_app/features/home/ui/widgets/anuncio_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_app_bar.dart';

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
                              final categoriaState = context
                                  .read<CategoriaBloc>()
                                  .state;
                              final selectedCategoriaId =
                                  categoriaState is CategoriaSuccess
                                  ? categoriaState.selectedCategoriaId
                                  : categoriaState is CategoriaLoading
                                  ? categoriaState.selectedCategoriaId
                                  : categoriaState is CategoriaError
                                  ? categoriaState.selectedCategoriaId
                                  : null;

                              context.read<HomeBloc>().add(
                                CargarCatalogo(
                                  categoriaId: selectedCategoriaId,
                                ),
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

                  if (state is HomeSuccess ||
                      state is HomeRefreshing ||
                      state is HomeRefreshError) {
                    final catalogo = state is HomeSuccess
                        ? state.catalogo
                        : state is HomeRefreshing
                        ? state.catalogo
                        : (state as HomeRefreshError).catalogo;
                    final anuncios = catalogo.content;
                    final isRefreshing = state is HomeRefreshing;
                    final refreshErrorMessage = state is HomeRefreshError
                        ? state.message
                        : null;

                    return ListView(
                      padding: const EdgeInsets.only(top: 24, bottom: 100),
                      children: [
                        BlocBuilder<CategoriaBloc, CategoriaState>(
                          builder: (context, categoriaState) {
                            if (categoriaState is CategoriaLoading ||
                                categoriaState is CategoriaInitial) {
                              return const SizedBox(
                                height: 40,
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (categoriaState is CategoriaError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        categoriaState.message,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.read<CategoriaBloc>().add(
                                          CargarCategorias(),
                                        );
                                      },
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (categoriaState is CategoriaSuccess) {
                              return CategoryFilter(
                                categorias: categoriaState.categorias,
                                selectedCategoriaId:
                                    categoriaState.selectedCategoriaId,
                                onCategoriaSelected: (newCategory) {
                                  context.read<CategoriaBloc>().add(
                                    SeleccionarCategoria(
                                      categoriaId: newCategory,
                                    ),
                                  );
                                  context.read<HomeBloc>().add(
                                    CargarCatalogo(categoriaId: newCategory),
                                  );
                                },
                              );
                            }

                            return const SizedBox.shrink();
                          },
                          
                        ),

                        if (isRefreshing)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              color: AppColors.primaryBlue,
                            ),
                          ),

                        if (refreshErrorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              left: 24,
                              right: 24,
                            ),
                            child: Text(
                              refreshErrorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),
                        if (anuncios.isEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
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
                            ),
                          )
                        else ...[
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
                            physics: ScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  print(
                                    "Abrir producto: ${anuncios[index].titulo}",
                                  );
                                },
                              );
                            },
                          ),
                        ],
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
