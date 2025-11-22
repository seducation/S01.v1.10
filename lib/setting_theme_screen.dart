import 'package:flutter/material.dart';

class SettingThemeScreen extends StatelessWidget {
  const SettingThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: const Center(
        child: Text(
          'Theme',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
