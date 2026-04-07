import 'package:flutter/foundation.dart';

class AppLogger {
  /// Debug log (only in debug mode)
  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[${tag ?? 'DEBUG'}] $message');
    }
  }

  /// Error log (always log or send to crash reporting service)
  static void e(String message, {dynamic error, StackTrace? stack}) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('Error Detail: $error');
      if (stack != null) debugPrint('Stack Trace: $stack');
    } else {
      // Release mode: You can integrate Sentry, Firebase Crashlytics, etc.
      // debugPrint('Silent error captured: $message');
    }
  }
}
