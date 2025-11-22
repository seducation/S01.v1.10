import 'package:flutter/material.dart';

class CNMNotificationsTabscreen extends StatelessWidget {
  const CNMNotificationsTabscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.notifications),
          title: Text('New message from Jane'),
          subtitle: Text('Hey, how are you?'),
        ),
      ],
    );
  }
}
