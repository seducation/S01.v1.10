import 'dart:async';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:my_app/calls/call_service.dart';
import 'package:my_app/calls/constants/call_constants.dart';
import 'package:my_app/calls/models/call_models.dart';
import 'package:my_app/calls/services/signaling_service.dart';

// Events
abstract class CallBlocEvent extends Equatable {
  const CallBlocEvent();

  @override
  List<Object?> get props => [];
}

class InitiateCallEvent extends CallBlocEvent {
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final CallType callType;

  const InitiateCallEvent({
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    this.callType = CallType.video,
  });

  @override
  List<Object?> get props => [
    receiverId,
    receiverName,
    receiverAvatar,
    callType,
  ];
}

class AcceptCallEvent extends CallBlocEvent {
  final CallData callData;

  const AcceptCallEvent(this.callData);

  @override
  List<Object?> get props => [callData];
}

class RejectCallEvent extends CallBlocEvent {
  final String callId;

  const RejectCallEvent(this.callId);

  @override
  List<Object?> get props => [callId];
}

class EndCallEvent extends CallBlocEvent {
  const EndCallEvent();
}

class CallTimeoutEvent extends CallBlocEvent {
  final String callId;

  const CallTimeoutEvent(this.callId);

  @override
  List<Object?> get props => [callId];
}

class RoomConnectedEvent extends CallBlocEvent {
  const RoomConnectedEvent();
}

class RoomDisconnectedEvent extends CallBlocEvent {
  const RoomDisconnectedEvent();
}

class IncomingCallReceivedEvent extends CallBlocEvent {
  final CallData callData;

  const IncomingCallReceivedEvent(this.callData);

  @override
  List<Object?> get props => [callData];
}

// States
abstract class CallBlocState extends Equatable {
  const CallBlocState();

  @override
  List<Object?> get props => [];
}

class CallIdle extends CallBlocState {
  const CallIdle();
}

class CallInitiating extends CallBlocState {
  final CallData callData;

  const CallInitiating(this.callData);

  @override
  List<Object?> get props => [callData];
}

class CallRinging extends CallBlocState {
  final CallData callData;

  const CallRinging(this.callData);

  @override
  List<Object?> get props => [callData];
}

class CallConnecting extends CallBlocState {
  final CallData callData;

  const CallConnecting(this.callData);

  @override
  List<Object?> get props => [callData];
}

class CallConnected extends CallBlocState {
  final CallData callData;
  final Room room;

  const CallConnected(this.callData, this.room);

  @override
  List<Object?> get props => [callData, room];
}

class CallReconnecting extends CallBlocState {
  final CallData callData;

  const CallReconnecting(this.callData);

  @override
  List<Object?> get props => [callData];
}

class CallEnded extends CallBlocState {
  final String reason;

  const CallEnded({this.reason = 'Call ended'});

  @override
  List<Object?> get props => [reason];
}

class CallFailed extends CallBlocState {
  final String error;

  const CallFailed(this.error);

  @override
  List<Object?> get props => [error];
}

class IncomingCall extends CallBlocState {
  final CallData callData;

  const IncomingCall(this.callData);

  @override
  List<Object?> get props => [callData];
}

// BLoC
class CallBloc extends Bloc<CallBlocEvent, CallBlocState> {
  final CallService _callService;
  final SignalingService _signalingService;

  CallData? _currentCallData;
  Timer? _timeoutTimer;
  StreamSubscription? _callEventsSubscription;
  StreamSubscription? _connectionStateSubscription;

  CallBloc({
    required CallService callService,
    required SignalingService signalingService,
  }) : _callService = callService,
       _signalingService = signalingService,
       super(const CallIdle()) {
    on<InitiateCallEvent>(_onInitiateCall);
    on<AcceptCallEvent>(_onAcceptCall);
    on<RejectCallEvent>(_onRejectCall);
    on<EndCallEvent>(_onEndCall);
    on<CallTimeoutEvent>(_onCallTimeout);
    on<RoomConnectedEvent>(_onRoomConnected);
    on<RoomDisconnectedEvent>(_onRoomDisconnected);
    on<IncomingCallReceivedEvent>(_onIncomingCallReceived);

    _initializeListeners();
  }

  /// Initialize listeners for call events and connection state
  void _initializeListeners() {
    // Listen to incoming call events
    _callEventsSubscription = _signalingService.callEvents.listen((callData) {
      add(IncomingCallReceivedEvent(callData));
    });

    // Listen to connection state changes
    _connectionStateSubscription = _callService.connectionStateStream.listen((
      connectionState,
    ) {
      if (connectionState == ConnectionState.connected &&
          state is CallConnecting) {
        add(const RoomConnectedEvent());
      } else if (connectionState == ConnectionState.disconnected &&
          state is CallConnected) {
        add(const RoomDisconnectedEvent());
      }
    });
  }

  /// Handle initiating a call
  Future<void> _onInitiateCall(
    InitiateCallEvent event,
    Emitter<CallBlocState> emit,
  ) async {
    try {
      // Create call through signaling service
      final callData = await _signalingService.createCall(
        receiverId: event.receiverId,
        receiverName: event.receiverName,
        receiverAvatar: event.receiverAvatar,
        callType: event.callType,
      );

      _currentCallData = callData;
      emit(CallInitiating(callData));

      // Start timeout timer
      _startTimeoutTimer(callData.callId);

      // Connect to LiveKit room
      emit(CallConnecting(callData));
      await _callService.connectToRoom(callData.roomName);
    } catch (e) {
      log('Error initiating call: $e');
      emit(CallFailed('Failed to initiate call: $e'));
    }
  }

  /// Handle accepting a call
  Future<void> _onAcceptCall(
    AcceptCallEvent event,
    Emitter<CallBlocState> emit,
  ) async {
    try {
      _currentCallData = event.callData;

      // Update call status to accepted
      await _signalingService.acceptCall(event.callData.callId);

      emit(CallConnecting(event.callData));

      // Connect to LiveKit room
      await _callService.connectToRoom(event.callData.roomName);
    } catch (e) {
      log('Error accepting call: $e');
      emit(CallFailed('Failed to accept call: $e'));
    }
  }

  /// Handle rejecting a call
  Future<void> _onRejectCall(
    RejectCallEvent event,
    Emitter<CallBlocState> emit,
  ) async {
    try {
      await _signalingService.rejectCall(event.callId);
      _cancelTimeoutTimer();
      emit(const CallEnded(reason: 'Call rejected'));
    } catch (e) {
      log('Error rejecting call: $e');
    }
  }

  /// Handle ending a call
  Future<void> _onEndCall(
    EndCallEvent event,
    Emitter<CallBlocState> emit,
  ) async {
    try {
      if (_currentCallData != null) {
        await _signalingService.endCall(
          _currentCallData!.callId,
          acceptedAt: _currentCallData!.acceptedAt,
        );
      }

      await _callService.disconnect();
      _cancelTimeoutTimer();
      _currentCallData = null;

      emit(const CallEnded());
    } catch (e) {
      log('Error ending call: $e');
      emit(const CallEnded(reason: 'Error ending call'));
    }
  }

  /// Handle call timeout
  Future<void> _onCallTimeout(
    CallTimeoutEvent event,
    Emitter<CallBlocState> emit,
  ) async {
    try {
      await _signalingService.timeoutCall(event.callId);
      await _callService.disconnect();
      _currentCallData = null;
      emit(const CallEnded(reason: 'Call timeout'));
    } catch (e) {
      log('Error handling timeout: $e');
    }
  }

  /// Handle room connected
  void _onRoomConnected(RoomConnectedEvent event, Emitter<CallBlocState> emit) {
    _cancelTimeoutTimer();
    if (_currentCallData != null && _callService.room != null) {
      final updatedCallData = _currentCallData!.copyWith(
        status: CallState.connected,
        acceptedAt: DateTime.now(),
      );
      _currentCallData = updatedCallData;
      emit(CallConnected(updatedCallData, _callService.room!));
    }
  }

  /// Handle room disconnected
  void _onRoomDisconnected(
    RoomDisconnectedEvent event,
    Emitter<CallBlocState> emit,
  ) {
    add(const EndCallEvent());
  }

  /// Handle incoming call received
  void _onIncomingCallReceived(
    IncomingCallReceivedEvent event,
    Emitter<CallBlocState> emit,
  ) {
    log('Incoming call received: ${event.callData.callId}');

    // Only emit if in idle state
    if (state is CallIdle) {
      emit(IncomingCall(event.callData));
      _startTimeoutTimer(event.callData.callId);
    }
  }

  /// Start timeout timer for ringing calls
  void _startTimeoutTimer(String callId) {
    _cancelTimeoutTimer();
    _timeoutTimer = Timer(CallConstants.callRingingTimeout, () {
      add(CallTimeoutEvent(callId));
    });
  }

  /// Cancel timeout timer
  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimeoutTimer();
    _callEventsSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _callService.dispose();
    return super.close();
  }
}
