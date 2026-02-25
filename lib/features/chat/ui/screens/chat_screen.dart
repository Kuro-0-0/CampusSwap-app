import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/chat_mensaje_model.dart';
import 'package:campusswap_app/core/services/anuncio_service.dart';
import 'package:campusswap_app/core/services/purchase_event_service.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/chat/bloc/chat_detalle_bloc.dart';
import 'package:campusswap_app/features/chat/ui/widgets/char_input_bar.dart';
import 'package:campusswap_app/features/chat/ui/widgets/chat_product_header.dart';
import 'package:campusswap_app/features/chat/ui/widgets/message_bubble.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:campusswap_app/features/profile/bloc/public_profile_bloc.dart';
import 'package:campusswap_app/features/profile/ui/screens/public_profile_screen.dart';
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
  late Anuncio _currentAnuncio;
  bool _isLoading = false;
  bool _isLoadingAnuncio = true;

  @override
  void initState() {
    super.initState();
    _currentAnuncio = widget.anuncio;
    _loadAnuncio();
    context.read<ChatDetalleBloc>().add(
      GetChatEspecifico(
        idAnuncio: widget.idAnuncio,
        idContrario: widget.idContrario,
      ),
    );
  }

  Future<void> _loadAnuncio() async {
    try {
      final anuncio = await AnuncioService().getAnuncioById(widget.idAnuncio);
      if (mounted) {
        setState(() {
          _currentAnuncio = anuncio;
          _isLoadingAnuncio = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAnuncio = false);
    }
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

  String _imageUrl(String imagen) {
    if (imagen.isEmpty)
      return 'https://via.placeholder.com/400x350.png?text=Sin+Imagen';

    if (imagen.startsWith('http')) return imagen;
    return '${TokenStorage.baseUrl}/api/v1/imagen/$imagen';
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
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => PublicProfileBloc()),
                    BlocProvider(create: (_) => ProfileBloc()..add(LoadProfile())),
                  ],
                  child: PublicProfileScreen(usuarioId: widget.idContrario),
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  _imageUrl(widget.fotoUsuario ?? ''),
                ),
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
          if (_isLoading) const LinearProgressIndicator(),
          if (_isLoadingAnuncio)
            const LinearProgressIndicator()
          else
            ChatProductHeader(
              tituloAnuncio: _currentAnuncio.titulo,
              imagenAnuncio: _currentAnuncio.imagen,
              anuncio: _currentAnuncio,
              onBuyTap: _handleBuy,
              isOwner: _currentAnuncio.usuarioId != widget.idContrario,
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

  Future<void> _handleBuy() async {
    setState(() => _isLoading = true);
    try {
      await AnuncioService().comprarAnuncio(widget.idAnuncio);

      final refreshedAnuncio = await AnuncioService().getAnuncioById(widget.idAnuncio);

      if (!mounted) return;
      setState(() => _currentAnuncio = refreshedAnuncio);

      // Send automatic purchase message to seller
      final purchaseMessage = "He comprado tu producto: ${widget.tituloAnuncio}";
      context.read<ChatDetalleBloc>().add(
        EnviarMensaje(
          contenido: purchaseMessage,
          anuncioId: widget.idAnuncio,
          receptorId: widget.idContrario,
        ),
      );

      PurchaseEventBus.instance.notifyPurchase(widget.idAnuncio);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Compra realizada con éxito!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString();
      final isAlreadyPurchased = errorMessage.contains('ya ha sido comprado');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );

      // If already purchased, refresh the page to update the button
      if (isAlreadyPurchased) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        final refreshedAnuncio = await AnuncioService().getAnuncioById(widget.idAnuncio);
        if (mounted) {
          setState(() => _currentAnuncio = refreshedAnuncio);
          PurchaseEventBus.instance.notifyPurchase(widget.idAnuncio);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
