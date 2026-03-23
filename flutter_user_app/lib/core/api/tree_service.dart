import 'package:flutter/foundation.dart';
import '../constants.dart';
import 'base_api_service.dart';

class TreeService {
  static Future<List<Map<String, dynamic>>> getTrees({
    int page = 1,
    int limit = 100,
    String? search,
    String? category,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
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

  static Future<List<Map<String, dynamic>>> getTreeImages(int treeId) async {
    final url = Uri.parse('${AppConstants.apiUrl}/trees?search=$treeId');
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

  static String getProxyImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.contains('/uploads/proxy') || !url.contains('drive.google.com')) {
      return url;
    }
    return '${AppConstants.apiUrl}/uploads/proxy?url=${Uri.encodeComponent(url)}';
  }
}
