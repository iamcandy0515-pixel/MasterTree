import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';

class QuizRepository extends BaseRepository {
  QuizRepository() : super();

  // --- From TreeRepository (단건 및 AI 관련 로직) ---

  Future<List<Map<String, dynamic>>> searchDriveFiles(String keyword) async {
    final url = Uri.parse('$baseUrl/external/drive-files/search');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'keyword': keyword}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return List<Map<String, dynamic>>.from(jsonResponse['data']);
      }
    }
    checkAuthError(response.statusCode);

    final errorMsg =
        jsonDecode(utf8.decode(response.bodyBytes))['error'] ?? '알 수 없는 오류';
    throw Exception('구글 드라이브 조회 실패: $errorMsg');
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
      body: jsonEncode({
        'fileId': fileId,
        'subject': subject,
        'year': year,
        'round': round,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'] as Map<String, dynamic>;
      }
    }
    checkAuthError(response.statusCode);

    final errorMsg =
        jsonDecode(utf8.decode(response.bodyBytes))['error'] ?? '알 수 없는 오류';
    throw Exception('구글 드라이브 파일 검증 실패: $errorMsg');
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
      body: jsonEncode({
        'fileId': fileId,
        'questionNumber': questionNumber,
        'optionsCount': optionsCount,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
    }
    checkAuthError(response.statusCode);

    final errorMsg =
        jsonDecode(utf8.decode(response.bodyBytes))['error'] ?? '알 수 없는 오류';
    throw Exception('문제 추출 실패: $errorMsg');
  }

  Future<Map<String, dynamic>> reviewQuizAlignment(
    String rawText,
    dynamic currentQuizBlocks,
  ) async {
    final url = Uri.parse('$baseUrl/quiz/review');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'rawText': rawText,
        'currentQuizBlocks': currentQuizBlocks,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['reviewResult'] ?? {};
      }
    }
    checkAuthError(response.statusCode);

    final errorMsg =
        jsonDecode(utf8.decode(response.bodyBytes))['error'] ?? '알 수 없는 오류';
    throw Exception('AI 검수 실패: $errorMsg');
  }

  Future<List<String>> generateHints(
    String questionText,
    String explanation,
    int count,
  ) async {
    final url = Uri.parse('$baseUrl/quiz/hints');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'questionText': questionText,
        'explanation': explanation,
        'count': count,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return List<String>.from(jsonResponse['data']['hints']);
      }
    }
    checkAuthError(response.statusCode);

    final errorMsg =
        jsonDecode(utf8.decode(response.bodyBytes))['error'] ?? '알 수 없는 오류';
    throw Exception('힌트 생성 실패: $errorMsg');
  }

  Future<List<String>> generateDistractors(
    String questionText,
    String correctOption,
  ) async {
    final url = Uri.parse('$baseUrl/quiz/distractors');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'questionText': questionText,
        'correctOption': correctOption,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return List<String>.from(jsonResponse['data']['distractors']);
      }
    }
    checkAuthError(response.statusCode);

    final errorMsg =
        jsonDecode(utf8.decode(response.bodyBytes))['error'] ?? '알 수 없는 오류';
    throw Exception('오답 생성 실패: $errorMsg');
  }

  Future<Map<String, dynamic>> upsertQuizQuestion(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/quiz/upsert');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
    }
    checkAuthError(response.statusCode);

    final errorMsg =
        jsonDecode(utf8.decode(response.bodyBytes))['error'] ?? '알 수 없는 오류';
    throw Exception('DB 저장 실패: $errorMsg');
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
      body: jsonEncode({'questionText': questionText, 'limit': limit}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['related'] ??
            jsonResponse['data'] as List<dynamic>;
      }
    }
    checkAuthError(response.statusCode);

    final errorMsg =
        jsonDecode(utf8.decode(response.bodyBytes))['error'] ?? '알 수 없는 오류';
    throw Exception('AI 연관 문제 추천 실패: $errorMsg');
  }

  // --- From NodeApi (일괄 및 공통 로직) ---

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
      body: jsonEncode({
        'fileId': fileId,
        'startNumber': startNumber,
        'endNumber': endNumber,
        'subject': subject,
        'year': year,
        'round': round,
      }),
    );

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      return json['data']['batchData'] ?? [];
    } else {
      checkAuthError(resp.statusCode);
      final error = jsonDecode(resp.body);
      throw Exception(error['message'] ?? '일괄 추출 실패');
    }
  }

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

    if (resp.statusCode == 200) {
      return true;
    } else {
      checkAuthError(resp.statusCode);
      final error = jsonDecode(resp.body);
      throw Exception(error['message'] ?? '일괄 등록 실패');
    }
  }

  Future<void> deleteQuiz(int id) async {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl/quiz/$id');

    final resp = await http.delete(uri, headers: headers);

    if (resp.statusCode != 200) {
      checkAuthError(resp.statusCode);
      throw Exception('삭제 요청 실패 (서버 오류: ${resp.statusCode})');
    }
  }

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

    if (resp.statusCode != 200) {
      checkAuthError(resp.statusCode);
      throw Exception('일괄 저장 실패: ${resp.body}');
    }
  }

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

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']['publicUrl'];
    } else {
      checkAuthError(response.statusCode);
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? '이미지 업로드 실패');
    }
  }
}
