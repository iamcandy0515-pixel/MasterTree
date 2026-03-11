import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessingUtil {
  /// Resizes image and encodes to WebP format.
  /// Standard thumbnail size is 300x300.
  static Future<Uint8List> generateWebpThumbnail(
    Uint8List originalBytes, {
    int width = 300,
    int height = 300,
  }) async {
    // 1. Decode original image
    final image = img.decodeImage(originalBytes);
    if (image == null) throw Exception('Failed to decode image');

    // 2. Resize maintaining aspect ratio (using contain or cover logic)
    // Here we use copyResize with interpolation for quality.
    final thumbnail = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );

    // 3. Encode to JPG (WebP encoding not supported in image package v4)
    final jpgBytes = img.encodeJpg(thumbnail);
    return Uint8List.fromList(jpgBytes);
  }

  /// Helper to get category name for filename rule (?€?? ê½? ?˜í”¼, ?? ?´ë§¤)
  static String getCategoryDisplayName(String type) {
    switch (type) {
      case 'main':
        return '?€??;
      case 'bark':
        return '?˜í”¼';
      case 'leaf':
        return '??;
      case 'flower':
        return 'ê½?;
      case 'fruit':
        return '?´ë§¤';
      default:
        return 'ê¸°í?';
    }
  }

  /// Generates rule-based filename: [TreeName]_[Category]_thumb.webp
  static String generateThumbnailFileName(String treeName, String type) {
    final displayName = getCategoryDisplayName(type);
    // Sanitize tree name (remove spaces)
    final sanitizedTreeName = treeName.replaceAll(RegExp(r'\s+'), '');
    return '${sanitizedTreeName}_${displayName}_thumb.webp';
  }
}
