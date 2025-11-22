import 'package:flutter/material.dart';

class SettingEmergencyScreen extends StatelessWidget {
  const SettingEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
      ),
      body: const Center(
        child: Text(
          'Emergency',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
