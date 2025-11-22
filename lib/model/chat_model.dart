class ChatModel {
  final String name;
  String message;
  String time;
  final String imgPath;
  final bool isOnline;
  int? messageCount;
  bool hasStory;

  ChatModel({
    required this.name,
    required this.message,
    required this.time,
    required this.imgPath,
    this.isOnline = false,
    this.messageCount,
    this.hasStory = false,
  });
}
