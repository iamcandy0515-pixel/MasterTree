import 'dart:convert';
import 'package:http/http.dart' as http;

mixin QuizRepositoryMixin {
  /// Standardized JSON response parser with UTF-8 support and error handling
  Map<String, dynamic> parseJsonResponse(http.Response response) {
    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
      if (decodedJson is! Map) {
        throw Exception('JSON 응답이 객체 형식이 아닙니다.');
      }
      final jsonResponse = Map<String, dynamic>.from(decodedJson);
      
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
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map) {
        final json = Map<String, dynamic>.from(decoded);
        return json['error'] ?? json['message'] ?? '알 수 없는 서버 오류';
      }
      return '서버 응답 파싱 실패';
    } catch (_) {
      return '서버 응답 파싱 실패';
    }
  }

  /// Simple check for successful extraction result
  T extractData<T>(http.Response response, String key) {
    final json = parseJsonResponse(response);
    final data = json['data'];
    if (data is Map && data.containsKey(key)) {
      final val = data[key];
      if (val is Map) return Map<String, dynamic>.from(val) as T;
      if (val is List) return List<dynamic>.from(val) as T;
      return val as T;
    }
    throw Exception('데이터에서 키($key)를 찾을 수 없습니다.');
  }
}
