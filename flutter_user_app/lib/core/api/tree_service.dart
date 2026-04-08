import 'package:flutter/foundation.dart';
import '../constants.dart';
import 'base_api_service.dart';

class TreeService {
  static Future<List<Map<String, dynamic>>> getTrees({
    int page = 1,
    int limit = 100,
    String? search,
    String? category,
    bool minimal = true,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'minimal': minimal.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category != '전체') 'category': category,
    };

    final url = Uri.parse('${AppConstants.apiUrl}/trees').replace(queryParameters: queryParams);

    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
        return data.map<Map<String, dynamic>>((dynamic e) {
          final Map<String, dynamic> tree = Map<String, dynamic>.from(e as Map);
          final List<dynamic>? images = tree['tree_images'] as List<dynamic>?;
          if (images != null && images.isNotEmpty) {
            final dynamic mainImg = images.firstWhere(
              (dynamic img) => (img as Map<String, dynamic>)['image_type'] == 'main',
              orElse: () => images[0],
            );
            final Map<String, dynamic> mainImgMap = mainImg as Map<String, dynamic>;
            // Cloudinary 최적화 URL을 우선 사용 (없으면 기존 image_url)
            tree['image_url'] = mainImgMap['quizz_source_image_url'] ?? mainImgMap['image_url'];
            tree['thumbnail_url'] = mainImgMap['thumbnail_url'];
          }
          return tree;
        }).toList();
      }
      throw Exception('Failed to load trees: ${jsonResponse['message']}');
    } catch (e) {
      debugPrint('TreeService.getTrees Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getTreeOne(int id) async {
    final Uri url = Uri.parse('${AppConstants.apiUrl}/trees/$id');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        return Map<String, dynamic>.from(jsonResponse['data'] as Map);
      }
    } catch (e) {
      debugPrint('TreeService.getTreeOne Error: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getTreeImages(int treeId) async {
    final Uri url = Uri.parse('${AppConstants.apiUrl}/trees?search=$treeId&minimal=false');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      final List<dynamic> data = (jsonResponse['data'] as List<dynamic>?) ?? <dynamic>[];
      if (jsonResponse['success'] == true && data.isNotEmpty) {
        final Map<String, dynamic> firstItem = Map<String, dynamic>.from(data[0] as Map);
        final List<dynamic> images = (firstItem['tree_images'] as List<dynamic>?) ?? <dynamic>[];
        return images.map((dynamic e) {
          final Map<String, dynamic> img = Map<String, dynamic>.from(e as Map);
          // UI 레이어에서 일관되게 사용할 수 있도록 이미지 필드 매핑 강화
          img['image_url'] = img['quizz_source_image_url'] ?? img['image_url'];
          return img;
        }).toList();
      }
    } catch (e) {
      debugPrint('TreeService.getTreeImages Error: $e');
    }
    return <Map<String, dynamic>>[];
  }

  static String getProxyImageUrl(String? url, {int? width, int? height}) {
    if (url == null || url.isEmpty) return '';

    // [0] Cloudinary URL은 이미 최적화되어 있으므로 그대로 반환 (프록시 불필요)
    if (url.contains('cloudinary.com')) {
      return url;
    }

    // [1] Supabase Storage 리사이징 활용 (가장 가벼움)
    if (url.contains('supabase.co/storage/v1/object/public/')) {
      if (width != null) {
        final separator = url.contains('?') ? '&' : '?';
        return '$url${separator}width=$width&quality=85';
      }
      return url;
    }

    // [2] 구글 드라이브 또는 외부 URL 프록시 리사이징
    if (url.contains('drive.google.com') || url.contains('googleusercontent.com')) {
      String proxyUrl = '${AppConstants.apiUrl}/uploads/proxy?url=${Uri.encodeComponent(url)}';
      if (width != null) proxyUrl += '&w=$width';
      if (height != null) proxyUrl += '&h=$height';
      return proxyUrl;
    }

    // [3] 이미 프록시 처리되었거나 기타 URL
    if (url.contains('/uploads/proxy')) {
      if (width != null && !url.contains('&w=')) return '$url&w=$width';
      return url;
    }

    return url;
  }
}
