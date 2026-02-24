import 'package:campusswap_app/core/models/anuncio_response_model.dart' show Anuncio;
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:campusswap_app/features/anuncio_detail/ui/screens/anuncio_detail_screen.dart';
import 'package:campusswap_app/features/home/bloc/home_bloc.dart';
import 'package:campusswap_app/features/panel_admin/bloc/panel_admin_bloc.dart';
import 'package:campusswap_app/features/panel_admin/ui/screens/manage_categorias_screen.dart';
import 'package:campusswap_app/features/categorias/bloc/categoria_bloc.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  late CategoriaBloc _categoriaBloc;

  @override
  void initState() {
    super.initState();
    _categoriaBloc = CategoriaBloc();
  }

  @override
  void dispose() {
    _categoriaBloc.close();
    super.dispose();
  }

  String _imageUrl(Anuncio anuncio) {
    if (anuncio.imagen.isEmpty)
      return 'https://via.placeholder.com/400x350.png?text=Sin+Imagen';

    if (anuncio.imagen.startsWith('http'))
      return anuncio.imagen;

    return '${TokenStorage.baseUrl}/api/v1/imagen/${anuncio.imagen}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<PanelAdminBloc, PanelAdminState>(
          builder: (context, state) {
            
            if (state is PanelAdminLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF7E22CE)));
            }

            if (state is PanelAdminError) {
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
                  onPressed: () {
                    context.read<PanelAdminBloc>().add(CargarEstadisticas());
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

            if (state is PanelAdminLoaded) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7E22CE), 
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Panel Admin",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Gestión de CampusSwap",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                            children: [
                              _buildStatCard(Icons.folder_outlined, "${state.totalAnuncios}", "Anuncios Activos", Colors.blue),
                              _buildStatCard(Icons.people_outline, "${state.usuariosActivos}", "Usuarios Activos", Colors.green),
                              _buildStatCard(Icons.warning_amber_rounded, "${state.reportesPendientes}", "Reportes Pendientes", Colors.orange),
                              _buildStatCard(Icons.bar_chart, "${state.categorias}", "Categorías", Colors.purple.shade300),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Acciones rápidas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 16),
                          _buildActionCard(Icons.folder_outlined, "Gestionar Categorías", "Crear, editar o eliminar categorías", Colors.blue.withOpacity(0.1), Colors.blue, onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => BlocProvider.value(
                                  value: _categoriaBloc,
                                  child: const ManageCategoriesScreen(),
                                ),
                              ),
                            );
                          }),
                          _buildActionCard(Icons.warning_amber_rounded, "Moderar Anuncios", "Revisar anuncios reportados", Colors.orange.withOpacity(0.1), Colors.orange),
                          _buildActionCard(Icons.people_outline, "Gestionar Usuarios", "Ver y administrar usuarios", Colors.green.withOpacity(0.1), Colors.green),
                          
                          const SizedBox(height: 24),
                          const Text("Últimos anuncios publicados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: state.anunciosRecientes.isEmpty 
                              ? const Center(child: Text("No hay anuncios publicados", style: TextStyle(color: Colors.grey)))
                              : Column(
                                  children: state.anunciosRecientes.map((anuncio) {
                                    return Column(
                                      children: [
                                        _buildAnuncioRecienteItem(context, anuncio),
                                        if (anuncio != state.anunciosRecientes.last) const Divider(height: 16),
                                      ],
                                    );
                                  }).toList(),
                                ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAnuncioRecienteItem(BuildContext context, Anuncio anuncio) {
    return InkWell(
      onTap: () async {
        final eliminado = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => BlocProvider.value(
              value: context.read<ProfileBloc>(),
              child: AnuncioDetailScreen(
                anuncio: anuncio,
                isMine: false, 
                isAdmin: true,
              ),
            ),
          ),
        );

        if (eliminado == true && context.mounted) {
          context.read<PanelAdminBloc>().add(CargarEstadisticas());
          context.read<HomeBloc>().add(CargarCatalogo());
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image(image: NetworkImage(_imageUrl(anuncio)), fit: BoxFit.cover,),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anuncio.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${anuncio.precio != null ? '${anuncio.precio} €' : 'Precio no disponible'} • ${anuncio.categoria}",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}