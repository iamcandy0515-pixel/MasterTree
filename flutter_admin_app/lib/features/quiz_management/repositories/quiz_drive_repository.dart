import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';
import './quiz_repository_mixin.dart';

class QuizDriveRepository extends BaseRepository with QuizRepositoryMixin {
  QuizDriveRepository() : super();

  // Simple in-memory cache for search results
  final Map<String, List<Map<String, dynamic>>> _searchCache = {};

  Future<List<Map<String, dynamic>>> searchDriveFiles(String keyword) async {
    if (_searchCache.containsKey(keyword)) return _searchCache[keyword]!;

    final url = Uri.parse('$baseUrl/external/drive-files/search');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{'keyword': keyword}),
    );

    final jsonResponse = parseJsonResponse(response);
    final results = List<Map<String, dynamic>>.from((jsonResponse['data'] as Iterable<dynamic>));
    
    // Cache for 10 minutes or simple map storage (per app lifecycle)
    _searchCache[keyword] = results;
    return results;
  }

  Future<Map<String, dynamic>> validateDriveFile(
    String fileId, {
    String? subject,
    int? year,
    int? round,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/validate-drive-file');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'fileId': fileId,
        'subject': subject,
        'year': year,
        'round': round,
      }),
    );

    final jsonResponse = parseJsonResponse(response);
    return jsonResponse['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> extractDriveFile(
    String fileId,
    int questionNumber,
    int optionsCount,
  ) async {
    final url = Uri.parse('$baseUrl/quiz/extract-drive-file');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'fileId': fileId,
        'questionNumber': questionNumber,
        'optionsCount': optionsCount,
      }),
    );

    final jsonResponse = parseJsonResponse(response);
    return jsonResponse['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> extractBatch({
    required String fileId,
    required int startNumber,
    required int endNumber,
    required String subject,
    required int year,
    required int round,
  }) async {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl/quiz/extract-batch');

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'fileId': fileId,
        'startNumber': startNumber,
        'endNumber': endNumber,
        'subject': subject,
        'year': year,
        'round': round,
      }),
    );

    final jsonResponse = parseJsonResponse(resp);
    return (jsonResponse['data'] as Map<String, dynamic>)['batchData'] as List<dynamic>? ?? <dynamic>[];
  }
}
