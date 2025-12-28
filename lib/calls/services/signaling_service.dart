import 'dart:async';
import 'dart:developer';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/calls/constants/call_constants.dart';
import 'package:my_app/calls/models/call_models.dart';
import 'package:uuid/uuid.dart';

/// Manages call signaling through Appwrite Realtime
class SignalingService {
  final AppwriteService _appwriteService;
  final _uuid = const Uuid();

  StreamSubscription? _callSubscription;
  final _callEventsController = StreamController<CallData>.broadcast();

  Stream<CallData> get callEvents => _callEventsController.stream;

  SignalingService(this._appwriteService);

  /// Initialize call event listening for the current user
  Future<void> startListening() async {
    final user = await _appwriteService.getUser();
    if (user == null) {
      log('Cannot start listening: User not authenticated');
      return;
    }

    try {
      // Subscribe to call events where current user is the receiver
      final subscription = await _appwriteService.subscribeToCollection(
        collectionId: CallConstants.callsCollectionId,
        callback: (event) {
          _handleCallEvent(event);
        },
      );

      _callSubscription = subscription as StreamSubscription?;
      log('Started listening for call events');
    } catch (e) {
      log('Error starting call listener: $e');
    }
  }

  /// Handle incoming call events
  void _handleCallEvent(dynamic event) {
    try {
      final payload = event.payload;
      if (payload == null) return;

      final callData = CallData.fromJson(payload as Map<String, dynamic>);
      _callEventsController.add(callData);
      log('Received call event: ${callData.status}');
    } catch (e) {
      log('Error handling call event: $e');
    }
  }

  /// Create a new call
  Future<CallData> createCall({
    required String receiverId,
    required String receiverName,
    String? receiverAvatar,
    CallType callType = CallType.video,
  }) async {
    final user = await _appwriteService.getUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userProfile = await _appwriteService.getUserProfile(user.$id);

    final callId = _uuid.v4();
    final roomName = 'room_${callId.replaceAll('-', '_')}';

    final callData = CallData(
      callId: callId,
      roomName: roomName,
      caller: CallUser(
        userId: user.$id,
        name: userProfile?['fullname'] ?? 'Unknown',
        avatarUrl: userProfile?['avatar'],
      ),
      receiver: CallUser(
        userId: receiverId,
        name: receiverName,
        avatarUrl: receiverAvatar,
      ),
      callType: callType,
      status: CallState.initiating,
      createdAt: DateTime.now(),
    );

    try {
      await _appwriteService.createCallDocument(callData);
      log('Created call document: $callId');
      return callData;
    } catch (e) {
      log('Error creating call: $e');
      rethrow;
    }
  }

  /// Accept an incoming call
  Future<void> acceptCall(String callId) async {
    try {
      await _appwriteService.updateCallDocument(
        callId: callId,
        status: CallState.connecting,
        acceptedAt: DateTime.now(),
      );
      log('Accepted call: $callId');
    } catch (e) {
      log('Error accepting call: $e');
      rethrow;
    }
  }

  /// Reject an incoming call
  Future<void> rejectCall(String callId) async {
    try {
      await _appwriteService.updateCallDocument(
        callId: callId,
        status: CallState.rejected,
        endedAt: DateTime.now(),
      );
      log('Rejected call: $callId');
    } catch (e) {
      log('Error rejecting call: $e');
      rethrow;
    }
  }

  /// End an active call
  Future<void> endCall(String callId, {DateTime? acceptedAt}) async {
    try {
      int? duration;
      if (acceptedAt != null) {
        duration = DateTime.now().difference(acceptedAt).inSeconds;
      }

      await _appwriteService.updateCallDocument(
        callId: callId,
        status: CallState.ended,
        endedAt: DateTime.now(),
        duration: duration,
      );
      log('Ended call: $callId');
    } catch (e) {
      log('Error ending call: $e');
      rethrow;
    }
  }

  /// Mark call as timeout
  Future<void> timeoutCall(String callId) async {
    try {
      await _appwriteService.updateCallDocument(
        callId: callId,
        status: CallState.timeout,
        endedAt: DateTime.now(),
      );
      log('Call timeout: $callId');
    } catch (e) {
      log('Error marking call as timeout: $e');
    }
  }

  /// Get active call for current user
  Future<CallData?> getActiveCall() async {
    try {
      final user = await _appwriteService.getUser();
      if (user == null) return null;

      return await _appwriteService.getActiveCallForUser(user.$id);
    } catch (e) {
      log('Error getting active call: $e');
      return null;
    }
  }

  /// Stop listening to call events
  void stopListening() {
    _callSubscription?.cancel();
    _callSubscription = null;
    log('Stopped listening for call events');
  }

  /// Dispose resources
  void dispose() {
    stopListening();
    _callEventsController.close();
  }
}
