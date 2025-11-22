import 'package:flutter/material.dart';

class CNMCallsTabscreen extends StatelessWidget {
  const CNMCallsTabscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.call),
          title: Text('Jane Doe'),
          subtitle: Text('Incoming call'),
          trailing: Text('11:30 AM'),
        ),
      ],
    );
  }
}
