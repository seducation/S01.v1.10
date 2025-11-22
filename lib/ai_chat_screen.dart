import 'package:flutter/material.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      // Simulate AI response
      _messages.add({'sender': 'ai', 'text': 'Echo: $text'});
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUserMessage = message['sender'] == 'user';

              return Align(
                alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isUserMessage ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    message['text']!,
                    style: TextStyle(
                      color: isUserMessage ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildMessageComposer(),
      ],
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_messageController.text),
          ),
        ],
      ),
    );
  }
}
