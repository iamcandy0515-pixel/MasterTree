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
      final jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) {
          final tree = Map<String, dynamic>.from(e);
          final images = tree['tree_images'] as List<dynamic>?;
          if (images != null && images.isNotEmpty) {
            final mainImg = images.firstWhere(
              (img) => img['image_type'] == 'main',
              orElse: () => images[0],
            );
            tree['image_url'] = mainImg['image_url'];
            // 썸네일 URL 데이터가 있으면 함께 매핑 (최적화 1단계)
            tree['thumbnail_url'] = mainImg['thumbnail_url'];
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
    final url = Uri.parse('${AppConstants.apiUrl}/trees/$id');
    try {
      final jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        return Map<String, dynamic>.from(jsonResponse['data']);
      }
    } catch (e) {
      debugPrint('TreeService.getTreeOne Error: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getTreeImages(int treeId) async {
    final url = Uri.parse('${AppConstants.apiUrl}/trees?search=$treeId&minimal=false');
    try {
      final jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true && jsonResponse['data'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(
          jsonResponse['data'][0]['tree_images'] ?? [],
        );
      }
    } catch (e) {
      debugPrint('TreeService.getTreeImages Error: $e');
    }
    return [];
  }

  static String getProxyImageUrl(String? url, {int? width, int? height}) {
    if (url == null || url.isEmpty) return '';

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
