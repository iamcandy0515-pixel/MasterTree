import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';
import './quiz_repository_mixin.dart';

class QuizRepository extends BaseRepository with QuizRepositoryMixin {
  QuizRepository() : super();

  /// Basic CRUD: Update or Insert a single quiz question
  Future<Map<String, dynamic>> upsertQuizQuestion(Map<String, dynamic> data) async {
    final Uri url = Uri.parse('$baseUrl/quiz/upsert');
    final Map<String, String> headers = await getHeaders();
    final http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    final Map<String, dynamic> jsonResponse = parseJsonResponse(response);
    return (jsonResponse['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  /// Delete a single quiz question by ID
  Future<void> deleteQuiz(int id) async {
    final Map<String, String> headers = await getHeaders();
    final Uri uri = Uri.parse('$baseUrl/quiz/$id');

    final http.Response resp = await http.delete(uri, headers: headers);
    parseJsonResponse(resp); // Generic error check and parsing
  }

  /// Bulk CRUD: Upsert multiple questions in one batch
  Future<bool> upsertBatch({
    required List<dynamic> quizItems,
    required Map<String, dynamic> examFilter,
  }) async {
    final Map<String, String> headers = await getHeaders();
    final Uri uri = Uri.parse('$baseUrl/quiz/upsert-batch');

    final http.Response resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(<String, dynamic>{'quizItems': quizItems, 'examFilter': examFilter}),
    );

    parseJsonResponse(resp);
    return true;
  }

  /// Bulk Recommendation Logic persistence
  Future<void> upsertRelatedBulk(Map<int, List<int>> relatedMap) async {
    final Map<String, String> headers = await getHeaders();
    final Uri uri = Uri.parse('$baseUrl/quiz/upsert-related-bulk');

    final Map<String, List<int>> serializableMap = relatedMap.map(
      (int key, List<int> value) => MapEntry<String, List<int>>(key.toString(), value),
    );

    final http.Response resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(<String, dynamic>{'relatedMap': serializableMap}),
    );

    parseJsonResponse(resp);
  }
}
