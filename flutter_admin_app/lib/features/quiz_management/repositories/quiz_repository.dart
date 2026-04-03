import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';
import './quiz_repository_mixin.dart';

class QuizRepository extends BaseRepository with QuizRepositoryMixin {
  QuizRepository() : super();

  /// Basic CRUD: Update or Insert a single quiz question
  Future<Map<String, dynamic>> upsertQuizQuestion(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/quiz/upsert');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    final jsonResponse = parseJsonResponse(response);
    final responseData = jsonResponse['data'];
    if (responseData == null) return {};
    return Map<String, dynamic>.from(responseData as Map);
  }

  /// Delete a single quiz question by ID
  Future<void> deleteQuiz(int id) async {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl/quiz/$id');

    final resp = await http.delete(uri, headers: headers);
    parseJsonResponse(resp); // Generic error check and parsing
  }

  /// Bulk CRUD: Upsert multiple questions in one batch
  Future<bool> upsertBatch({
    required List<dynamic> quizItems,
    required Map<String, dynamic> examFilter,
  }) async {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl/quiz/upsert-batch');

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'quizItems': quizItems, 'examFilter': examFilter}),
    );

    parseJsonResponse(resp);
    return true;
  }

  /// Bulk Recommendation Logic persistence
  Future<void> upsertRelatedBulk(Map<int, List<int>> relatedMap) async {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl/quiz/upsert-related-bulk');

    final serializableMap = relatedMap.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'relatedMap': serializableMap}),
    );

    parseJsonResponse(resp);
  }
}
