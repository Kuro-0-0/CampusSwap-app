import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;

  const HomeAppBar({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25,),
          Row(
            children: [
              Text(
                "Hola, ",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "$userName 👋",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}