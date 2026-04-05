import 'dart:convert';
import 'package:http/http.dart' as http;

mixin QuizRepositoryMixin {
  /// Standardized JSON response parser with UTF-8 support and error handling
  Map<String, dynamic> parseJsonResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return jsonResponse;
      }
      throw Exception(jsonResponse['error']?.toString() ?? '알 수 없는 결과 오류');
    }
    
    // Non-200 responses
    final String errorMsg = _tryExtractErrorMessage(response);
    throw Exception('이미 서버에서 오류가 발생했습니다 (${response.statusCode}): $errorMsg');
  }

  String _tryExtractErrorMessage(http.Response response) {
    try {
      final Map<String, dynamic> json = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return json['error']?.toString() ?? json['message']?.toString() ?? '알 수 없는 서버 오류';
    } catch (_) {
      return '서버 응답 파싱 실패';
    }
  }

  /// Simple check for successful extraction result
  T extractData<T>(http.Response response, String key) {
    final Map<String, dynamic> json = parseJsonResponse(response);
    final Map<String, dynamic> data = (json['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return data[key] as T;
  }
}
