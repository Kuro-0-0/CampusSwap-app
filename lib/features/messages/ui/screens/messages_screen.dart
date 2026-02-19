import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/messages/bloc/mensaje_bloc.dart';
import 'package:campusswap_app/features/messages/ui/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesScreen extends StatefulWidget {
  final int idAnuncio;
  const MessagesScreen({super.key, required this.idAnuncio});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MensajeBloc>().add(ObtenerMensajes(widget.idAnuncio));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabecera
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

            // 2. Barra de búsqueda
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
                    // TODO: filtrar lista localmente
                  },
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // 3. Lista desde BLoC
            Expanded(
              child: BlocBuilder<MensajeBloc, MensajeState>(
                builder: (context, state) {
                  if (state is MensajeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MensajeFailure) {
                    return Center(child: Text(state.message));
                  } else if (state is MensajeSuccess) {
                    final mensajes = state.data.content;

                    if (mensajes.isEmpty) return _buildEmptyState();

                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 0, bottom: 20),
                      itemCount: mensajes.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color(0xFFF5F5F5),
                        indent: 90,
                      ),
                      itemBuilder: (context, index) {
                        return ConversationTile(
                          mensaje: mensajes[index], // ← directo, sin mapper
                          onTap: () {
                            // TODO: navegar al chat
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
          Text("No tienes mensajes aún", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
