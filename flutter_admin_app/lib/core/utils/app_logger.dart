import 'package:flutter/foundation.dart';

class AppLogger {
  /// Debug log (only in debug mode)
  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[${tag ?? 'ADMIN-DEBUG'}] $message');
    }
  }

  /// Error log (logged with detailed trace in debug, silenced/monitored in release)
  static void e(String message, {dynamic error, StackTrace? stack}) {
    if (kDebugMode) {
      debugPrint('[ADMIN-ERROR] $message');
      if (error != null) debugPrint('Error Detail: $error');
      if (stack != null) debugPrint('Stack Trace: $stack');
    } else {
      // In production, send to sentry/analytics
    }
  }
}
