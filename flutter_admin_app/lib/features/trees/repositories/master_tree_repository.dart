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
    final String cacheKey = 'trees_p${page}_l${limit}_s${search}_c${category}_m$minimal';
    final PaginatedTrees? cached = getCachedData<PaginatedTrees>(cacheKey);
    if (cached != null) return cached;

    final Map<String, String> queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'minimal': minimal.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category != '전체') 'category': category,
    };

    final Uri url = Uri.parse('$baseUrl/trees').replace(queryParameters: queryParams);
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = (jsonResponse['data'] as List<dynamic>?) ?? <dynamic>[];
        final Map<String, dynamic> meta = (jsonResponse['meta'] as Map<String, dynamic>?) ?? <String, dynamic>{};

        final PaginatedTrees result = PaginatedTrees(
          trees: data.map((dynamic e) => Tree.fromJson(e as Map<String, dynamic>)).toList(),
          total: (meta['total'] as int?) ?? 0,
          page: (meta['page'] as int?) ?? 1,
          limit: (meta['limit'] as int?) ?? 20,
          totalPages: (meta['totalPages'] as int?) ?? 1,
        );
        setCachedData(cacheKey, result);
        return result;
      }
    }
    throw Exception('수목 목록 로드 실패: ${response.statusCode}');
  }

  // GET /api/trees/random
  Future<List<String>> getRandomTrees({
    required int count,
    String? category,
    String? excludeName,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'count': count.toString(),
      if (category != null) 'category': category,
      if (excludeName != null) 'excludeName': excludeName,
    };

    final Uri url = Uri.parse('$baseUrl/trees/random').replace(queryParameters: queryParams);
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = (jsonResponse['data'] as List<dynamic>?) ?? <dynamic>[];
        return data.map((dynamic e) => e.toString()).toList();
      }
    }
    return <String>[];
  }

  // GET /api/trees/:id
  Future<Tree> getTreeById(int id) async {
    final Uri url = Uri.parse('$baseUrl/trees/$id');
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return Tree.fromJson(jsonResponse['data'] as Map<String, dynamic>);
      }
    }
    throw Exception('수목 상세 정보 로드 실패: ${response.statusCode}');
  }

  // CRUD Operations
  Future<Tree> updateTree(int id, CreateTreeRequest request) async {
    final Uri url = Uri.parse('$baseUrl/trees/$id');
    final Map<String, String> headers = await getHeaders();
    final http.Response response = await http.put(url, headers: headers, body: jsonEncode(request.toJson()));

    if (response.statusCode == 200) {
      invalidateTreeCache();
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Tree.fromJson(jsonResponse['data'] as Map<String, dynamic>);
    }
    checkAuthError(response.statusCode);
    throw Exception('수목 수정 실패: ${response.statusCode}');
  }

  Future<void> deleteTree(int id) async {
    final Uri url = Uri.parse('$baseUrl/trees/$id');
    final Map<String, String> headers = await getHeaders();
    final http.Response response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      invalidateTreeCache();
      return;
    }
    checkAuthError(response.statusCode);
    throw Exception('수목 삭제 실패: ${response.statusCode}');
  }

  Future<Tree> createTree(CreateTreeRequest request) async {
    final Uri url = Uri.parse('$baseUrl/trees');
    final Map<String, String> headers = await getHeaders();
    final http.Response response = await http.post(url, headers: headers, body: jsonEncode(request.toJson()));

    if (response.statusCode == 200 || response.statusCode == 201) {
      invalidateTreeCache();
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Tree.fromJson(jsonResponse['data'] as Map<String, dynamic>);
    }
    checkAuthError(response.statusCode);
    throw Exception('이미 서버에서 오류가 발생했습니다 (${response.statusCode})');
  }
}
