import 'package:campusswap_app/core/models/usuario_response_model.dart';
import 'package:campusswap_app/core/models/reporte_request_model.dart';
import 'package:campusswap_app/core/services/anuncio_service.dart';
import 'package:campusswap_app/core/services/profile_service.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:campusswap_app/features/anuncio_detail/ui/widgets/vendedor_card.dart';
import 'package:campusswap_app/features/chat/bloc/chat_detalle_bloc.dart';
import 'package:campusswap_app/features/chat/ui/screens/chat_screen.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/anuncio_form/ui/screens/anuncio_form_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnuncioDetailScreen extends StatelessWidget {
  final Anuncio anuncio;
  final bool isMine;
  final bool isAdmin;

  const AnuncioDetailScreen({
    super.key,
    required this.anuncio,
    this.isMine = false,
    this.isAdmin = false,
  });

  String get _imageUrl {
    if (anuncio.imagen.isEmpty)
      return 'https://via.placeholder.com/400x350.png?text=Sin+Imagen';

    if (anuncio.imagen.startsWith('http')) return anuncio.imagen;
    return '${TokenStorage.baseUrl}/api/v1/imagen/${anuncio.imagen}?v=h';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCircleButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              if (!isMine && !isAdmin)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      bool isFavorited = false;
                      int? favoritoId;

                      if (state is ProfileLoaded) {
                        bool existe = state.favoritos.any(
                          (f) => f.anuncio.titulo == anuncio.titulo,
                        );

                        if (existe) {
                          final fav = state.favoritos.firstWhere(
                            (f) => f.anuncio.titulo == anuncio.titulo,
                          );
                          isFavorited = true;
                          favoritoId = fav.id;
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          if (isFavorited && favoritoId != null) {
                            context.read<ProfileBloc>().add(
                              DeleteFavorito(favoritoId: favoritoId),
                            );
                          } else {
                            context.read<ProfileBloc>().add(
                              AddFavorito(anuncioId: anuncio.id),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorited
                                ? Colors.red
                                : AppColors.textDark,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (!isMine && !isAdmin)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildReportDropdown(context),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anuncio.titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Text(
                        anuncio.precio != null
                            ? "${anuncio.precio} €"
                            : anuncio.tipoOperacion,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          anuncio.condicion,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      anuncio.categoria,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Descripción",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    anuncio.descripcion,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Vendedor",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  FutureBuilder<UsuarioResponse>(
                    future: ProfileService().getPublicUserProfile(
                      anuncio.usuarioId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return VendedorCard(
                          name: isMine ? "Tú" : "Usuario del anuncio",
                          rating: null,
                          date: isMine
                              ? "Este es tu anuncio"
                              : "Error al cargar datos",
                          usuarioId: isMine ? null : anuncio.usuarioId,
                          imagen:
                              snapshot.data?.imageUrl ??
                              "https://via.placeholder.com/400x350.png?text=Sin+Imagen",
                        );
                      }

                      final vendedor = snapshot.data!;

                      final date = vendedor.fechaRegistro;
                      const monthNames = [
                        'Ene',
                        'Feb',
                        'Mar',
                        'Abr',
                        'May',
                        'Jun',
                        'Jul',
                        'Ago',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dic',
                      ];
                      final dateString =
                          "${monthNames[date.month - 1]} ${date.year}";

                      return VendedorCard(
                        name: isMine
                            ? "Tú (${vendedor.nombre})"
                            : vendedor.nombre,
                        rating: vendedor.reputacionMedia ?? null,
                        date: isMine
                            ? "Este es tu anuncio"
                            : "Miembro desde $dateString",
                        usuarioId: isMine ? null : anuncio.usuarioId,
                        imagen: vendedor.imageUrl,
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomSheet: isMine
          ? _buildOwnerActions(context)
          : isAdmin
          ? _buildAdminActions(context)
          : _buildBuyerActions(context),
    );
  }

  Widget _buildOwnerActions(BuildContext context) {
    final isPaused = anuncio.estado == 'PAUSADO';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AnuncioFormScreen(anuncioAEditar: anuncio),
                    ),
                  ).then((editado) {
                    if (editado == true) {
                      Navigator.pop(context, 'recargar');
                    }
                  });
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Editar", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pop(context, isPaused ? 'reactivar' : 'pausar'),
                icon: Icon(
                  isPaused
                      ? Icons.play_circle_outline
                      : Icons.pause_circle_outline,
                  size: 16,
                ),
                label: Text(
                  isPaused ? "Reactivar" : "Pausar",
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _mostrarConfirmacionEliminar(context),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text("Borrar", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            );

            try {
              final vendedor = await ProfileService().getPublicUserProfile(
                anuncio.usuarioId,
              );

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => ChatDetalleBloc(),
                      child: ChatScreen(
                        userName: vendedor.nombre,
                        fotoUsuario: vendedor.imageUrl.isNotEmpty
                            ? vendedor.imageUrl
                            : null,
                        idAnuncio: anuncio.id,
                        idContrario: anuncio.usuarioId,
                        tituloAnuncio: anuncio.titulo,
                        imagenAnuncio: anuncio.imagen,
                        precioAnuncio: anuncio.precio ?? 0.0,
                        anuncio: anuncio,
                      ),
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al intentar abrir el chat.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text("Iniciar chat"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarConfirmacionEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Anuncio"),
        content: const Text(
          "¿Estás seguro de que quieres eliminar este anuncio? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, 'eliminar');
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textDark, size: 20),
      ),
    );
  }

  Widget _buildReportDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: AppColors.textDark, size: 20),
        onSelected: (String motivo) {
          _mostrarConfirmacionReporte(context, motivo);
        },
        itemBuilder: (BuildContext context) =>
            motivosDisponibles.map((MotivoOption motivo) {
          return PopupMenuItem<String>(
            value: motivo.valor,
            child: Text(motivo.label),
          );
        }).toList(),
      ),
    );
  }

  void _mostrarConfirmacionReporte(BuildContext context, String motivo) {
    final motivoOption = motivosDisponibles.firstWhere(
      (m) => m.valor == motivo,
      orElse: () => MotivoOption(valor: motivo, label: motivo),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reportar anuncio'),
        content: Text(
          '¿Estás seguro de que deseas reportar este anuncio por: ${motivoOption.label}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _enviarReporte(context, motivo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarReporte(BuildContext context, String motivo) async {
    try {
      final anuncioService = AnuncioService();
      await anuncioService.reportarAnuncio(anuncio.id, motivo);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anuncio reportado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAdminActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Eliminar anuncio"),
                content: const Text(
                  "¿Estás seguro de que deseas eliminar este anuncio como Administrador? Esta acción no se puede deshacer y el anuncio desaparecerá del catálogo.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        ),
                      );

                      await Future.delayed(const Duration(milliseconds: 300));

                      try {
                        await AnuncioService().eliminarAnuncioAdmin(anuncio.id);

                        if (context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Anuncio eliminado por moderación.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al eliminar el anuncio.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Eliminar",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.delete_forever),
          label: const Text("Eliminar Anuncio (Moderar)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
