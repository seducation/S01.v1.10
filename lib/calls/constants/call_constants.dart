import 'package:flutter/material.dart';

/// Centralized constants for call management
class CallConstants {
  // Timeout durations
  static const Duration callRingingTimeout = Duration(seconds: 30);
  static const Duration callReconnectionTimeout = Duration(seconds: 30);
  static const Duration tokenRefreshInterval = Duration(minutes: 50);

  // Video quality presets
  static const Map<String, Map<String, int>> videoQualityPresets = {
    'low': {'width': 320, 'height': 240, 'frameRate': 15},
    'medium': {'width': 640, 'height': 480, 'frameRate': 24},
    'high': {'width': 1280, 'height': 720, 'frameRate': 30},
  };

  // Audio/Video constraints
  static const int defaultAudioBitrate = 32000; // 32 kbps
  static const int defaultVideoBitrate = 1000000; // 1 Mbps
  static const int maxVideoBitrate = 2500000; // 2.5 Mbps

  // ICE configuration
  static const List<Map<String, dynamic>> defaultIceServers = [
    {
      'urls': ['stun:stun.l.google.com:19302'],
    },
    {
      'urls': ['stun:stun1.l.google.com:19302'],
    },
  ];

  // Reconnection parameters
  static const int maxReconnectionAttempts = 3;
  static const Duration reconnectionDelay = Duration(seconds: 2);
  static const double reconnectionDelayMultiplier = 1.5;

  // UI constants
  static const double localVideoWidth = 120.0;
  static const double localVideoHeight = 160.0;
  static const double controlsBottomPadding = 40.0;
  static const double controlButtonSize = 56.0;
  static const double controlButtonSpacing = 20.0;

  // Colors
  static const Color acceptButtonColor = Colors.green;
  static const Color rejectButtonColor = Colors.red;
  static const Color mutedColor = Colors.grey;
  static const Color activeColor = Colors.white;
  static const Color reconnectingOverlayColor = Colors.black54;

  // Animation durations
  static const Duration controlsAutoHideDuration = Duration(seconds: 5);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 300);

  // Network quality thresholds
  static const int excellentQualityThreshold = 80;
  static const int goodQualityThreshold = 50;
  static const int poorQualityThreshold = 20;

  // Appwrite collection
  static const String callsCollectionId = 'calls';

  // Maximum call duration (in hours) - 0 means unlimited
  static const int maxCallDurationHours = 0;
}
