import 'package:campusswap_app/core/models/mensaje_response_model.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  final Mensaje mensaje;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.mensaje,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(mensaje.fotoEmisor),
        backgroundColor: Colors.grey[200],
      ),
      title: Text(
        mensaje.nombreEmisor,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        mensaje.mensaje,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        mensaje.fechaMensaje,
        style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
      ),
    );
  }
}
