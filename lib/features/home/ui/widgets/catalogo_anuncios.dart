import 'package:campusswap_app/features/anuncio_detail/ui/screens/anuncio_detail_screen.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/home/bloc/home_bloc.dart';
import 'package:campusswap_app/features/home/ui/widgets/anuncio_card.dart';

class CatalogoAnunciosWidget extends StatelessWidget {
  final Widget? topContent;

  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;

  const CatalogoAnunciosWidget({
    super.key,
    this.topContent,
    required this.onRetry,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                  onPressed: onRetry,
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

          return RefreshIndicator(
            onRefresh: onRefresh,
            color: AppColors.primaryBlue,
            backgroundColor: Colors.white,
            child: ListView(
              padding: const EdgeInsets.only(top: 24, bottom: 100),
              children: [
                if (topContent != null) topContent!,

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
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 24),

                if (anuncios.isEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
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
                            'No se encontraron anuncios',
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
                          "Anuncios",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          "${anuncios.length} resultados",
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => BlocProvider.value(
                                value: context
                                    .read<
                                      ProfileBloc
                                    >(),
                                child: AnuncioDetailScreen(
                                  anuncio: anuncios[index],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
