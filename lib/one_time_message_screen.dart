
import 'dart:async';
import 'package:flutter/material.dart';

class OneTimeMessageScreen extends StatefulWidget {
  final String message;
  final VoidCallback onStoryViewed;

  const OneTimeMessageScreen({
    super.key,
    required this.message,
    required this.onStoryViewed,
  });

  @override
  OneTimeMessageScreenState createState() => OneTimeMessageScreenState();
}

class OneTimeMessageScreenState extends State<OneTimeMessageScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate viewing the story and then going back
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onStoryViewed();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          widget.message,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
