// features/chat/ui/screens/chat_screen.dart

import 'package:campusswap_app/core/models/chat_mensaje_model.dart';
import 'package:campusswap_app/features/chat/bloc/chat_detalle_bloc.dart';
import 'package:campusswap_app/features/chat/ui/widgets/char_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/chat_product_header.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String? fotoUsuario;
  final int idAnuncio;
  final String idContrario;
  final String tituloAnuncio;
  final String imagenAnuncio;
  final double precioAnuncio;

  const ChatScreen({
    super.key,
    required this.userName,
    this.fotoUsuario,
    required this.idAnuncio,
    required this.idContrario,
    required this.tituloAnuncio,
    required this.imagenAnuncio,
    required this.precioAnuncio,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

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
    super.dispose();
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          // 1. Cabecera del anuncio
          ChatProductHeader(
            tituloAnuncio: widget.tituloAnuncio,
            imagenAnuncio: widget.imagenAnuncio,
            precioAnuncio: widget.precioAnuncio,
            onBuyTap: () {
              // TODO: proceso de pago
            },
          ),

          // 2. Lista de mensajes
          Expanded(
            child: BlocBuilder<ChatDetalleBloc, ChatDetalleState>(
              builder: (context, state) {
                if (state is ChatDetalleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatDetalleFailure) {
                  return Center(child: Text(state.error));
                }
                if (state is ChatDetalleSuccess) {
                  if (state.mensajes.isEmpty) {
                    return const Center(child: Text("No hay mensajes aún."));
                  }
                  return _buildListaMensajes(state.mensajes);
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // 3. Input
          ChatInputBar(
            controller: _controller,
            onSendTap: () {
              // TODO: evento de enviar mensaje
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListaMensajes(List<ChatMensajeResponse> mensajes) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: mensajes.length,
      itemBuilder: (context, index) {
        final msg = mensajes[index];
        final esMio = msg.idEmisor == widget.idContrario ? false : true;
        return MessageBubble(
          text: msg.mensaje,
          time: msg.fechaMensaje,
          isMe: esMio,
        );
      },
    );
  }
}
