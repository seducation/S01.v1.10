import 'package:livekit_client/livekit_client.dart';

class CallService {
  final String _url = 'wss://my-new-project-21vhn4cm.livekit.cloud'; // Correct: Your LiveKit URL

  // IMPORTANT: This token must be generated from your server and should be short-lived.
  // Do NOT hardcode your API Secret here.
  final String _token = 'YOUR_LIVEKIT_TOKEN';

  Future<Room> connectToRoom(String roomName) async {
    final room = Room(
      roomOptions: const RoomOptions(
        adaptiveStream: true,
        dynacast: true,
      ),
    );

    // In a real app, you would fetch the token from your server here
    // before connecting.
    await room.connect(
      _url,
      _token,
    );

    return room;
  }
}
