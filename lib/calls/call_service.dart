import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/calls/constants/call_constants.dart';
import 'package:my_app/calls/services/media_manager.dart';
import 'package:my_app/environment.dart';

/// Enhanced service for managing LiveKit room connections and call lifecycle
class CallService {
  final AppwriteService _appwriteService;
  final MediaManager mediaManager;

  lk.Room? _room;
  Timer? _reconnectionTimer;
  int _reconnectionAttempts = 0;
  bool _isDisposed = false;

  final _connectionStateController =
      StreamController<lk.ConnectionState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<lk.ConnectionState> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<String> get errorStream => _errorController.stream;

  lk.Room? get room => _room;
  bool get isConnected =>
      _room?.connectionState == lk.ConnectionState.connected;

  CallService(this._appwriteService, {MediaManager? mediaManager})
    : mediaManager = mediaManager ?? MediaManager();

  /// Connect to a LiveKit room
  Future<lk.Room> connectToRoom(String roomName) async {
    if (_isDisposed) {
      throw Exception('CallService has been disposed');
    }

    try {
      log('Connecting to room: $roomName');

      // Create room with optimized settings
      _room = lk.Room(
        roomOptions: const lk.RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: lk.AudioPublishOptions(
            name: 'microphone',
            audioBitrate: CallConstants.defaultAudioBitrate,
          ),
          defaultVideoPublishOptions: lk.VideoPublishOptions(
            name: 'camera',
            videoEncoding: lk.VideoEncoding(
              maxBitrate: CallConstants.defaultVideoBitrate,
              maxFramerate: 30,
            ),
          ),
        ),
      );

      // Setup connection state listener
      _room!.addListener(_onRoomStateChanged);

      // Get LiveKit token
      final token = await _appwriteService.getLiveKitToken(roomName: roomName);

      // Connect to room (roomOptions moved to constructor as per deprecation)
      await _room!.connect(Environment.liveKitUrl, token);

      log('Connected to room: $roomName');

      // Set room in media manager
      mediaManager.setRoom(_room!);

      // Initialize and publish local media
      await mediaManager.initializeLocalMedia();
      await mediaManager.publishLocalTracks();

      _reconnectionAttempts = 0;
      return _room!;
    } catch (e) {
      log('Error connecting to room: $e');
      _errorController.add('Failed to connect: $e');
      rethrow;
    }
  }

  /// Handle room state changes
  void _onRoomStateChanged() {
    if (_room == null) return;

    final state = _room!.connectionState;
    _connectionStateController.add(state);
    log('Room connection state changed: $state');

    switch (state) {
      case lk.ConnectionState.connecting:
        log('Room is connecting...');
        break;
      case lk.ConnectionState.disconnected:
        _handleDisconnection();
        break;
      case lk.ConnectionState.reconnecting:
        log('Room is reconnecting...');
        break;
      case lk.ConnectionState.connected:
        log('Room connected successfully');
        _reconnectionAttempts = 0;
        _reconnectionTimer?.cancel();
        break;
    }
  }

  /// Handle disconnection and attempt reconnection
  void _handleDisconnection() {
    if (_isDisposed) return;

    if (_reconnectionAttempts < CallConstants.maxReconnectionAttempts) {
      _reconnectionAttempts++;
      final delay =
          CallConstants.reconnectionDelay *
          CallConstants.reconnectionDelayMultiplier *
          _reconnectionAttempts;

      log(
        'Attempting reconnection $_reconnectionAttempts in ${delay.inSeconds}s',
      );

      _reconnectionTimer?.cancel();
      _reconnectionTimer = Timer(delay, () {
        // LiveKit SDK handles reconnection automatically
        log('Reconnection attempt $_reconnectionAttempts');
      });
    } else {
      log('Max reconnection attempts reached');
      _errorController.add('Connection lost. Please try again.');
    }
  }

  /// Disconnect from the room
  Future<void> disconnect() async {
    try {
      log('Disconnecting from room');
      _reconnectionTimer?.cancel();

      await mediaManager.stopLocalTracks();
      await _room?.disconnect();
      _room?.removeListener(_onRoomStateChanged);
      _room?.dispose();
      _room = null;

      log('Disconnected successfully');
    } catch (e) {
      log('Error disconnecting: $e');
    }
  }

  /// Handle app lifecycle changes
  Future<void> handleAppLifecycleChange(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        log('App paused - keeping audio, pausing video');
        if (mediaManager.mediaState.isVideoEnabled) {
          await mediaManager.toggleVideo();
        }
        break;
      case AppLifecycleState.resumed:
        log('App resumed - resuming video');
        if (!mediaManager.mediaState.isVideoEnabled) {
          await mediaManager.toggleVideo();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Do nothing for these states
        break;
    }
  }

  /// Dispose all resources
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    log('Disposing CallService');

    await disconnect();
    await mediaManager.dispose();

    _connectionStateController.close();
    _errorController.close();
    _reconnectionTimer?.cancel();
  }
}
