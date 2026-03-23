import 'dart:convert';
import 'package:http/http.dart' as http;

mixin QuizRepositoryMixin {
  /// Standardized JSON response parser with UTF-8 support and error handling
  Map<String, dynamic> parseJsonResponse(http.Response response) {
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse;
      }
      throw Exception(jsonResponse['error'] ?? '알 수 없는 결과 오류');
    }
    
    // Non-200 responses
    final errorMsg = _tryExtractErrorMessage(response);
    throw Exception('이미 서버에서 오류가 발생했습니다 (${response.statusCode}): $errorMsg');
  }

  String _tryExtractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json['error'] ?? json['message'] ?? '알 수 없는 서버 오류';
    } catch (_) {
      return '서버 응답 파싱 실패';
    }
  }

  /// Simple check for successful extraction result
  T extractData<T>(http.Response response, String key) {
    final json = parseJsonResponse(response);
    return json['data'][key] as T;
  }
}
