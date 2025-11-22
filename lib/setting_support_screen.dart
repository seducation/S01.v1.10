import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ai_chat_screen.dart';

class SettingSupportScreen extends StatelessWidget {
  const SettingSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const AIChatScreen(),
    );
  }
}
