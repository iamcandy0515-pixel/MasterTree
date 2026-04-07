// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';

class WebUtilsPlatform {
  static void downloadFile(String data, String filename) {
    final bytes = utf8.encode(data);
    final blob = html.Blob(<dynamic>[bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
    html.Url.revokeObjectUrl(url);
  }

  static void registerViewFactory(
    String viewId,
    Object Function(int) factory,
  ) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, factory);
  }

  static Object createDropZoneElement({
    required void Function() onDragOver,
    required void Function() onDragLeave,
    required void Function(dynamic files) onDrop,
    required void Function() onClick,
  }) {
    final element =
        html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.cursor = 'pointer';

    element.onDragOver.listen((event) {
      event.preventDefault();
      onDragOver();
    });

    element.onDragLeave.listen((event) {
      onDragLeave();
    });

    element.onDrop.listen((event) {
      event.preventDefault();
      onDrop(event.dataTransfer.files);
    });

    element.onClick.listen((event) {
      onClick();
    });

    return element;
  }

  static Future<void> pasteImageFromClipboard(
    Function(List<int> bytes, String name, String type) onImageReady,
  ) async {
    final clipboardData = await html.window.navigator.clipboard!.read();
    // ignore: unnecessary_null_comparison
    if (clipboardData == null || clipboardData.items == null) return;

    for (var i = 0; i < (clipboardData.items?.length ?? 0); i++) {
      final item = clipboardData.items![i];
      final type = item.type;
      if (type != null && type.startsWith('image/')) {
        final blob = item.getAsFile();
        if (blob == null) continue;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        await reader.onLoad.first;
        final bytes = reader.result as Uint8List;
        onImageReady(
          bytes,
          'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.${type.split('/')[1]}',
          type,
        );
        return;
      }
    }
  }

  static Future<Uint8List?> readFileAsBytes(dynamic file) async {
    if (file is! html.File) return null;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    return reader.result as Uint8List;
  }
}
