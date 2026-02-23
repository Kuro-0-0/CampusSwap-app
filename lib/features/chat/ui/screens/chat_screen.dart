import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/chat_mensaje_model.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/chat/bloc/chat_detalle_bloc.dart';
import 'package:campusswap_app/features/chat/ui/widgets/char_input_bar.dart';
import 'package:campusswap_app/features/chat/ui/widgets/chat_product_header.dart';
import 'package:campusswap_app/features/chat/ui/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String? fotoUsuario;
  final int idAnuncio;
  final String idContrario;
  final String tituloAnuncio;
  final String imagenAnuncio;
  final double precioAnuncio;
  final Anuncio anuncio;

  const ChatScreen({
    super.key,
    required this.userName,
    this.fotoUsuario,
    required this.idAnuncio,
    required this.idContrario,
    required this.tituloAnuncio,
    required this.imagenAnuncio,
    required this.precioAnuncio,
    required this.anuncio,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatDetalleBloc>().add(
      GetChatEspecifico(
        idAnuncio: widget.idAnuncio,
        idContrario: widget.idContrario,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _enviarMensaje() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    context.read<ChatDetalleBloc>().add(
      EnviarMensaje(
        contenido: texto,
        anuncioId: widget.idAnuncio,
        receptorId: widget.idContrario,
      ),
    );

    _controller.clear();
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.fotoUsuario != null
                  ? NetworkImage(widget.fotoUsuario!)
                  : null,
              child: widget.fotoUsuario == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          ChatProductHeader(
            tituloAnuncio: widget.tituloAnuncio,
            imagenAnuncio: widget.imagenAnuncio,
            precioAnuncio: widget.precioAnuncio,
            anuncio: widget.anuncio,
            onBuyTap: () {},
          ),
          Expanded(
            child: BlocConsumer<ChatDetalleBloc, ChatDetalleState>(
              listener: (context, state) {
                if (state is ChatDetalleSuccess) {
                  _scrollAlFinal();
                }
              },
              builder: (context, state) {
                if (state is ChatDetalleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatDetalleEnviado) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatDetalleFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textDark),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<ChatDetalleBloc>().add(
                              GetChatEspecifico(
                                idAnuncio: widget.idAnuncio,
                                idContrario: widget.idContrario,
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ChatDetalleSuccess) {
                  if (state.mensajes.isEmpty) {
                    return const Center(
                      child: Text(
                        "Sé el primero en escribir 👋",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return _buildListaMensajes(state.mensajes);
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          ChatInputBar(controller: _controller, onSendTap: _enviarMensaje),
        ],
      ),
    );
  }

  Widget _buildListaMensajes(List<ChatMensajeResponse> mensajes) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: mensajes.length,
      itemBuilder: (context, index) {
        final msg = mensajes[index];
        final esMio = msg.idEmisor != widget.idContrario;
        return MessageBubble(
          text: msg.mensaje,
          time: msg.fechaMensaje,
          isMe: esMio,
        );
      },
    );
  }
}
