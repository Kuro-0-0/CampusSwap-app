import 'package:campusswap_app/core/models/mensaje_response_model.dart';
import 'package:campusswap_app/core/services/token_storage_service.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/profile/bloc/profile_bloc.dart';
import 'package:campusswap_app/features/profile/bloc/public_profile_bloc.dart';
import 'package:campusswap_app/features/profile/ui/screens/public_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationTile extends StatelessWidget {
  final Conversacion conversacion;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversacion,
    required this.onTap,
  });

  String _timeAgo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
    if (diff.inDays == 1) return 'Ayer';
    return '${fecha.day}/${fecha.month}';
  }

  String get _imageUrl {
    if (conversacion.anuncio.imagen.isEmpty)
      return 'https://via.placeholder.com/400x350.png?text=Sin+Imagen';

    if (conversacion.anuncio.imagen.startsWith('http'))
      return conversacion.anuncio.imagen;

    return '${TokenStorage.baseUrl}/api/v1/imagen/${conversacion.anuncio.imagen}';
  }

  @override
  Widget build(BuildContext context) {
    final otro = conversacion.otroParticipante;
    final esMio = conversacion.ultimoMensajeEsMio;

    return ListTile(
      onTap: onTap,
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => PublicProfileBloc()),
                  BlocProvider.value(value: context.read<ProfileBloc>()),
                ],
                child: PublicProfileScreen(usuarioId: otro.id),
              ),
            ),
          );
        },
        child: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(_imageUrl),
              child: conversacion.anuncio.imagen.isEmpty
                  ? Text(
                      otro.nombre[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        conversacion.anuncio.titulo,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            otro.nombre,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${esMio ? 'Tú: ' : ''}${conversacion.ultimoMensaje.contenido}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Text(
        _timeAgo(conversacion.ultimoMensaje.fechaEnvio),
        style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
      ),
    );
  }
}
