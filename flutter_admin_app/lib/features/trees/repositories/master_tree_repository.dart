import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';
import '../models/tree.dart';
import '../models/create_tree_request.dart';
import './parts/master_tree_cache_mixin.dart';

class PaginatedTrees {
  final List<Tree> trees;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedTrees({
    required this.trees,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}

class MasterTreeRepository extends BaseRepository with MasterTreeCacheMixin {
  // GET /api/trees with Pagination
  Future<PaginatedTrees> getTrees({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    bool minimal = true,
  }) async {
    final cacheKey = '${generateCacheKey(page, limit, search, category)}&minimal=$minimal';
    final cached = getCachedData<PaginatedTrees>(cacheKey);
    if (cached != null) return cached;

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'minimal': minimal.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category != '전체') 'category': category,
    };

    final url = Uri.parse('$baseUrl/trees').replace(queryParameters: queryParams);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        final meta = jsonResponse['meta'];

        final result = PaginatedTrees(
          trees: data.map((e) => Tree.fromJson(e)).toList(),
          total: meta['total'] ?? 0,
          page: meta['page'] ?? 1,
          limit: meta['limit'] ?? 20,
          totalPages: meta['totalPages'] ?? 1,
        );
        setCachedData(cacheKey, result);
        return result;
      }
    }
    throw Exception('수목 목록 로드 실패: ${response.body}');
  }

  // GET /api/trees/random
  Future<List<String>> getRandomTrees({
    required int count,
    String? category,
    String? excludeName,
  }) async {
    final queryParams = {
      'count': count.toString(),
      if (category != null) 'category': category,
      if (excludeName != null) 'excludeName': excludeName,
    };

    final url = Uri.parse('$baseUrl/trees/random').replace(queryParameters: queryParams);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  // GET /api/trees/:id
  Future<Tree> getTreeById(int id) async {
    final url = Uri.parse('$baseUrl/trees/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return Tree.fromJson(jsonResponse['data']);
      }
    }
    throw Exception('수목 상세 정보 로드 실패: ${response.body}');
  }

  // CRUD Operations
  Future<Tree> updateTree(int id, CreateTreeRequest request) async {
    final url = Uri.parse('$baseUrl/trees/$id');
    final headers = await getHeaders();
    final response = await http.put(url, headers: headers, body: jsonEncode(request.toJson()));

    if (response.statusCode == 200) {
      invalidateTreeCache();
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return Tree.fromJson(jsonResponse['data']);
    }
    checkAuthError(response.statusCode);
    throw Exception('수목 수정 실패: ${response.body}');
  }

  Future<void> deleteTree(int id) async {
    final url = Uri.parse('$baseUrl/trees/$id');
    final headers = await getHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      invalidateTreeCache();
      return;
    }
    checkAuthError(response.statusCode);
    throw Exception('수목 삭제 실패: ${response.body}');
  }

  Future<Tree> createTree(CreateTreeRequest request) async {
    final url = Uri.parse('$baseUrl/trees');
    final headers = await getHeaders();
    final response = await http.post(url, headers: headers, body: jsonEncode(request.toJson()));

    if (response.statusCode == 200 || response.statusCode == 201) {
      invalidateTreeCache();
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return Tree.fromJson(jsonResponse['data']);
    }
    checkAuthError(response.statusCode);
    throw Exception('수목 생성 실패: ${response.body}');
  }
}
