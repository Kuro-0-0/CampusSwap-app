import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/chat/bloc/chat_detalle_bloc.dart';
import 'package:campusswap_app/features/chat/ui/screens/chat_screen.dart';
import 'package:campusswap_app/features/messages/bloc/mensaje_bloc.dart';
import 'package:campusswap_app/features/messages/ui/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late MensajeBloc _mensajeBloc;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _mensajeBloc = MensajeBloc()..add(GetChats());
  }

  @override
  void dispose() {
    _mensajeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "Mensajes",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Buscar conversaciones...",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            Expanded(
              child: BlocBuilder<MensajeBloc, MensajeState>(
                bloc: _mensajeBloc,
                builder: (context, state) {
                  if (state is MensajeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MensajeFailure) {
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
                            onPressed: () => _mensajeBloc.add(GetChats()),
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
                  } else if (state is MensajeSuccess) {
                    final conversaciones = state.response.content
                        .where((c) => c.ultimoMensaje.contenido
                            .toLowerCase()
                            .contains(_searchQuery))
                        .toList();

                    if (conversaciones.isEmpty) return _buildEmptyState();

                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 0, bottom: 20),
                      itemCount: conversaciones.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color(0xFFF5F5F5),
                        indent: 90,
                      ),
                      itemBuilder: (context, index) {
                        final conversacion = conversaciones[index];
                        final otro = conversacion.otroParticipante;

                        return ConversationTile(
                          conversacion: conversacion,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => ChatDetalleBloc(),
                                  child: ChatScreen(
                                    userName: otro.nombre,
                                    fotoUsuario: conversacion.anuncio.imagen,
                                    idAnuncio: conversacion.anuncio.id,
                                    idContrario: otro.id,
                                    tituloAnuncio: conversacion.anuncio.titulo,
                                    imagenAnuncio: conversacion.anuncio.imagen,
                                    precioAnuncio: conversacion.anuncio.precio,
                                    anuncio: conversacion.anuncio.toAnuncio(),
                                  ),
                                ),
                              ),
                            ).then((_) {
                              _mensajeBloc.add(GetChats());
                            });
                          },
                        );
                      },
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No tienes mensajes aún",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
