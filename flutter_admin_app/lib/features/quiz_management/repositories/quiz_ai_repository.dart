import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';
import './quiz_repository_mixin.dart';

class QuizAiRepository extends BaseRepository with QuizRepositoryMixin {
  QuizAiRepository() : super();

  // Simple caching for AI results to reduce redundant server costs
  final Map<String, List<String>> _hintCache = {};
  final Map<String, List<String>> _distractorCache = {};

  Future<Map<String, dynamic>> reviewQuizAlignment(
    String rawText,
    dynamic currentQuizBlocks,
  ) async {
    final url = Uri.parse('$baseUrl/quiz/review');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'rawText': rawText,
        'currentQuizBlocks': currentQuizBlocks,
      }),
    );

    final Map<String, dynamic> jsonResponse = parseJsonResponse(response);
    final Map<String, dynamic>? data = jsonResponse['data'] as Map<String, dynamic>?;
    return (data?['reviewResult'] as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  Future<List<String>> generateHints(
    String questionText,
    String explanation,
    int count,
  ) async {
    final cacheKey = '$questionText-$explanation';
    if (_hintCache.containsKey(cacheKey)) return _hintCache[cacheKey]!;

    final url = Uri.parse('$baseUrl/quiz/hints');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'questionText': questionText,
        'explanation': explanation,
        'count': count,
      }),
    );

    final Map<String, dynamic> jsonResponse = parseJsonResponse(response);
    final Map<String, dynamic>? data = jsonResponse['data'] as Map<String, dynamic>?;
    final List<String> results = List<String>.from((data?['hints'] as Iterable<dynamic>?) ?? <dynamic>[]);
    _hintCache[cacheKey] = results;
    return results;
  }

  Future<List<String>> generateDistractors(
    String questionText,
    String correctOption,
  ) async {
    final cacheKey = '$questionText-$correctOption';
    if (_distractorCache.containsKey(cacheKey)) return _distractorCache[cacheKey]!;

    final url = Uri.parse('$baseUrl/quiz/distractors');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'questionText': questionText,
        'correctOption': correctOption,
      }),
    );

    final Map<String, dynamic> jsonResponse = parseJsonResponse(response);
    final Map<String, dynamic>? data = jsonResponse['data'] as Map<String, dynamic>?;
    final List<String> results = List<String>.from((data?['distractors'] as Iterable<dynamic>?) ?? <dynamic>[]);
    _distractorCache[cacheKey] = results;
    return results;
  }

  Future<List<dynamic>> recommendRelated({
    required String questionText,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/recommend-related');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{'questionText': questionText, 'limit': limit}),
    );

    final Map<String, dynamic> jsonResponse = parseJsonResponse(response);
    final Map<String, dynamic>? data = jsonResponse['data'] as Map<String, dynamic>?;
    
    if (data != null && data['related'] != null) {
      return data['related'] as List<dynamic>;
    }
    return (data?['items'] as List<dynamic>?) ?? <dynamic>[];
  }
}
