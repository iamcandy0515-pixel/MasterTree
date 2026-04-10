import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/supabase_service.dart';

/// Service to monitor session hijacking or multi-device login conflicts.
/// Complies with [Rule 1-1] by separating logic from SupabaseService.
class SessionMonitorService {
  static StreamSubscription? _subscription;
  static String? _currentSessionId;
  static VoidCallback? _onLogoutRequired;

  /// Starts monitoring the 'users' table for changes to the current user's session.
  /// [currentSessionId] should be the full access token (it will be truncated internally).
  static void startMonitoring({
    required String authId,
    required String currentSessionId,
    required VoidCallback onLogoutRequired,
  }) {
    // 1. Clean up existing subscription
    stopMonitoring();

    // 2. Setup state
    _currentSessionId = currentSessionId.length > 20 
        ? currentSessionId.substring(0, 20) 
        : currentSessionId;
    _onLogoutRequired = onLogoutRequired;

    debugPrint('--- SESSION_MONITOR: Initializing for $authId');

    // 3. Subscribe to Realtime Stream for the specific user row
    try {
      _subscription = SupabaseService.client
          .from('users')
          .stream(primaryKey: ['auth_id'])
          .eq('auth_id', authId)
          .listen((data) {
            if (data.isEmpty) return;

            final Map<String, dynamic> userData = data.first;
            final String? dbSessionId = userData['last_session_id']?.toString();

            if (dbSessionId != null && dbSessionId != _currentSessionId) {
              debugPrint('--- SESSION_MONITOR: Conflict! (DB: $dbSessionId, Local: $_currentSessionId)');
              _onLogoutRequired?.call();
              stopMonitoring(); // Stop after first trigger to prevent loops
            }
          }, onError: (Object error) {
            debugPrint('--- SESSION_MONITOR_ERROR: $error');
          });
    } catch (e) {
      debugPrint('--- SESSION_MONITOR_EXCEPTION: $e');
    }
  }

  /// Stops the realtime session monitor.
  static void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
    _currentSessionId = null;
    _viewingDeviceModel = null;
    debugPrint('--- SESSION_MONITOR: Disconnected');
  }

  static String? _viewingDeviceModel;
  static void setDeviceModel(String model) => _viewingDeviceModel = model;
  static String get deviceModel => _viewingDeviceModel ?? "다른 기기";
}
