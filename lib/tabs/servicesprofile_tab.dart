import 'package:flutter/material.dart';

class ShortsTab extends StatelessWidget {
  final String profileId;
  const ShortsTab({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Shorts Content", style: TextStyle(color: Colors.white)),
    );
  }
}
