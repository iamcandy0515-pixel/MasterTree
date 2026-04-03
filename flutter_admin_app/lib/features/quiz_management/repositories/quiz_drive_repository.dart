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

    final dynamic decoded = parseJsonResponse(response);
    if (decoded is! Map) return [];
    final jsonResponse = Map<String, dynamic>.from(decoded);
    
    final dynamic rawData = jsonResponse['data'];
    if (rawData is! List) return [];
    
    final List<Map<String, dynamic>> results = (rawData as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    
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

    final dynamic decoded = parseJsonResponse(response);
    if (decoded is! Map) return <String, dynamic>{};
    final jsonResponse = Map<String, dynamic>.from(decoded);
    
    final dynamic rawData = jsonResponse['data'];
    if (rawData is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(rawData as Map);
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

    final dynamic decoded = parseJsonResponse(response);
    if (decoded is! Map) return <String, dynamic>{};
    final jsonResponse = Map<String, dynamic>.from(decoded);
    
    final dynamic rawData = jsonResponse['data'];
    if (rawData is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(rawData as Map);
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

    final dynamic decoded = parseJsonResponse(resp);
    if (decoded is! Map) return [];
    final jsonResponse = Map<String, dynamic>.from(decoded);
    
    final dynamic rawData = jsonResponse['data'];
    if (rawData is! Map || rawData['batchData'] is! List) return [];
    
    return (rawData['batchData'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
