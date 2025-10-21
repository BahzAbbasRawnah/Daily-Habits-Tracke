import 'package:flutter/material.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/chat/screens/chat_screen.dart';

class AIChatFAB extends StatelessWidget {
  const AIChatFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      },
      backgroundColor: AppTheme.primaryColor,
      elevation: 6,
      child: const Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
