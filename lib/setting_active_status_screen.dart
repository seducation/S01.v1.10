import 'package:flutter/material.dart';

class SettingActiveStatusScreen extends StatelessWidget {
  const SettingActiveStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Status'),
      ),
      body: const Center(
        child: Text(
          'Active Status',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
