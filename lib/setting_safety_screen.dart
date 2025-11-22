import 'package:flutter/material.dart';

class SettingSafetyScreen extends StatelessWidget {
  const SettingSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety'),
      ),
      body: const Center(
        child: Text(
          'Safety',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
