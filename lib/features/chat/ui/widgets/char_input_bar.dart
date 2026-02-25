import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendTap;

  const ChatInputBar({super.key, 
  required this.controller,
  required this.onSendTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Escribe algo...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context,value, _){
                final hasText= value.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: hasText ? onSendTap : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: hasText
                      ? AppColors.primaryBlue
                      : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send,color: Colors.white,size: 20),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}