import 'package:flutter/material.dart';
import 'package:my_app/add_post_screen.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;
import 'package:my_app/one_time_message_screen.dart';
import 'package:my_app/profile_screen.dart';
import 'package:my_app/search_screen.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<models.Row> _messages = [];
  bool _isLoading = false;
  String? _error;
  models.User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndMessages();
  }

  Future<void> _loadCurrentUserAndMessages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final appwriteService = context.read<AppwriteService>();
      _currentUser = await appwriteService.getUser();
      if (_currentUser != null) {
        await _fetchMessages();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMessages() async {
    if (_currentUser == null) return;
    try {
      final appwriteService = context.read<AppwriteService>();
      final messages = await appwriteService.getMessages(
        userId1: _currentUser!.$id,
        userId2: widget.receiverId,
      );
      setState(() {
        _messages.clear();
        _messages.addAll(messages.rows);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _currentUser == null) {
      return;
    }

    try {
      final appwriteService = context.read<AppwriteService>();
      await appwriteService.sendMessage(
        senderId: _currentUser!.$id,
        receiverId: widget.receiverId,
        message: _messageController.text,
      );
      _messageController.clear();
      await _fetchMessages();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        title: Text('Chat with ${widget.receiverId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPostScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    appwriteService: context.read<AppwriteService>(),
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu item selection
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _currentUser == null
                        ? const Center(child: Text('Please log in to view messages.'))
                        : ListView.builder(
                            reverse: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isMe = message.data['senderId'] == _currentUser!.$id;
                              final isOtm = message.data['isOtm'] ?? false;

                              if (isOtm) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OneTimeMessageScreen(
                                          message: message,
                                        ),
                                      ),
                                    ).then((_) => _fetchMessages());
                                  },
                                  child: Align(
                                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      margin: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: isMe ? Colors.blue : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: const Text(
                                        'Tap to view one-time message',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  margin: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    message.data['message'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
