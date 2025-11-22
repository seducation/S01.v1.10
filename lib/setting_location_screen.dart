import 'package:flutter/material.dart';

class SettingLocationScreen extends StatelessWidget {
  const SettingLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
      ),
      body: const Center(
        child: Text(
          'Location',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
