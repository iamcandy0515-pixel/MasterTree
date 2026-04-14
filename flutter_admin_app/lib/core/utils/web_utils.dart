import 'dart:typed_data';
import 'web_utils_stub.dart' if (dart.library.html) 'web_utils_web.dart';

class WebUtils {
  static void downloadFile(String data, String filename) =>
      WebUtilsPlatform.downloadFile(data, filename);

  static void registerViewFactory(
    String viewId,
    dynamic Function(int) factory,
  ) => WebUtilsPlatform.registerViewFactory(viewId, factory);

  static Object createDropZoneElement({
    required void Function() onDragOver,
    required void Function() onDragLeave,
    required void Function(dynamic files) onDrop,
    required void Function() onClick,
  }) => WebUtilsPlatform.createDropZoneElement(
    onDragOver: onDragOver,
    onDragLeave: onDragLeave,
    onDrop: onDrop,
    onClick: onClick,
  );

  static Future<void> pasteImageFromClipboard(
    Function(List<int> bytes, String name, String type) onImageReady,
  ) => WebUtilsPlatform.pasteImageFromClipboard(onImageReady);

  static Future<Uint8List?> readFileAsBytes(dynamic file) =>
      WebUtilsPlatform.readFileAsBytes(file);
}
