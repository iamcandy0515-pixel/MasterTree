import 'package:flutter/foundation.dart';

class WebUtilsPlatform {
  static void downloadFile(String data, String filename) {
    // Mobile: No-op (Should use path_provider and share_plus for real mobile support)
    debugPrint('Download not supported on this platform: $filename');
  }

  static void registerViewFactory(String viewId, dynamic Function(int) factory) {
    // Mobile: No-op
  }

  static Future<void> pasteImageFromClipboard(
    Function(List<int> bytes, String name, String type) onImageReady,
  ) async {
    // Mobile: No-op
  }

  static dynamic createDropZoneElement({
    required void Function() onDragOver,
    required void Function() onDragLeave,
    required void Function(dynamic files) onDrop,
    required void Function() onClick,
  }) {
    return null;
  }

  static Future<List<int>?> readFileAsBytes(dynamic file) async {
    return null;
  }
}
