import 'package:flutter/material.dart';
import 'package:my_app/ai_chat_screen.dart';

class SrvAimodeTabscreen extends StatefulWidget {
  const SrvAimodeTabscreen({super.key});

  @override
  State<SrvAimodeTabscreen> createState() => _SrvAimodeTabscreenState();
}

class _SrvAimodeTabscreenState extends State<SrvAimodeTabscreen> {
  @override
  Widget build(BuildContext context) {
    return const AIChatScreen();
  }
}
