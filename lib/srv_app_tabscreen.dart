
import 'package:flutter/material.dart';

class SrvAppTabscreen extends StatefulWidget {
  const SrvAppTabscreen({super.key});

  @override
  State<SrvAppTabscreen> createState() => _SrvAppTabscreenState();
}

class _SrvAppTabscreenState extends State<SrvAppTabscreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("App Content"),
    );
  }
}
