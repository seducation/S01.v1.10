import 'package:flutter/material.dart';

class SettingAppPermissionScreen extends StatelessWidget {
  const SettingAppPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Permission'),
      ),
      body: const Center(
        child: Text(
          'App Permission',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
