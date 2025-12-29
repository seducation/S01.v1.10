import 'package:flutter/material.dart';
import 'package:my_app/one_time_message_screen.dart';

class SentPostScreen extends StatelessWidget {
  final List<String> imagePaths;
  const SentPostScreen({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Send To'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'OTM'),
              Tab(text: 'Chat'),
              Tab(text: 'Other Apps'),
              Tab(text: 'Post'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  OTMSelectionList(imagePaths: imagePaths),
                  Center(child: Text('Chat')),
                  Center(child: Text('Other Apps')),
                  Center(child: Text('Post')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
