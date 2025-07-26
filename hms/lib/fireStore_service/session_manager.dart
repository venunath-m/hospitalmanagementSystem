import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Timer? _inactivityTimer;
  Duration timeoutDuration = const Duration(minutes: 10);
  VoidCallback? onTimeoutCallback;

  void startTracking(VoidCallback onTimeout) {
    onTimeoutCallback = onTimeout;
    _resetTimer();
  }

  void userActivityDetected() {
    _resetTimer();
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeoutDuration, () async {
      if (onTimeoutCallback != null) {
        onTimeoutCallback!();
      }
    });
  }

  void stopTracking() {
    _inactivityTimer?.cancel();
  }

  void dispose() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    onTimeoutCallback = null;
  }
}
