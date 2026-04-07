import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';
import './quiz_repository_mixin.dart';

class QuizMediaRepository extends BaseRepository with QuizRepositoryMixin {
  QuizMediaRepository() : super();

  Future<String> uploadQuizImage(Uint8List bytes, String fileName) async {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl/uploads/quiz-image');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.headers.remove('Content-Type');

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final jsonResponse = parseJsonResponse(response);
    return (jsonResponse['data'] as Map<String, dynamic>)['publicUrl'] as String;
  }
}
