import 'package:flutter/material.dart';
import 'package:my_app/select_contact_screen.dart';
import 'package:my_app/cnm_calls_tabscreen.dart';
import 'package:my_app/cnm_chats_tabscreen.dart';
import 'package:my_app/cnm_meeting_tabscreen.dart';
import 'package:my_app/model/chat_model.dart';
import 'package:my_app/cnm_notifications_tabscreen.dart';
import 'package:my_app/cnm_updates_tabscreen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late List<ChatModel> _chatItems;

  @override
  void initState() {
    super.initState();
    _chatItems = [
      ChatModel(
        name: "User 1",
        message: "Hello there!",
        time: "12:30 PM",
        imgPath: "https://picsum.photos/seed/p1/200/200",
        isOnline: true,
        messageCount: 2,
        hasStory: true,
      ),
      ChatModel(
        name: "User 2",
        message: "How are you?",
        time: "12:35 PM",
        imgPath: "https://picsum.photos/seed/p2/200/200",
        hasStory: true,
      ),
      ChatModel(
        name: "User 3",
        message: "See you soon.",
        time: "12:40 PM",
        imgPath: "https://picsum.photos/seed/p3/200/200",
        isOnline: true,
        messageCount: 1,
      ),
    ];
  }

  void _addNewChat(ChatModel newChat) {
    setState(() {
      _chatItems.insert(0, newChat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("MyApps"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.notifications)),
              Tab(text: "Updates"),
              Tab(text: "Chat"),
              Tab(text: "Meeting"),
              Tab(icon: Icon(Icons.call)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const CNMNotificationsTabscreen(),
            const CNMUpdatesTabscreen(),
            CNMChatsTabscreen(chatItems: _chatItems),
            const CNMMeetingTabscreen(),
            const CNMCallsTabscreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectContactScreen(onNewChat: _addNewChat),
              ),
            );
          },
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }
}
