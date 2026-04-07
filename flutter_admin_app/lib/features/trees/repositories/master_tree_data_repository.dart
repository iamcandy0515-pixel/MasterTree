import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/repositories/base_repository.dart';

class MasterTreeDataRepository extends BaseRepository {
  // Export CSV
  Future<String> exportTrees() async {
    final url = Uri.parse('$baseUrl/trees/export');
    final headers = await getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    }
    checkAuthError(response.statusCode);
    throw Exception('수목 데이터 내보내기 실패: ${response.body}');
  }

  // Import CSV
  Future<Map<String, dynamic>> importTrees(
    List<int> bytes,
    String fileName,
  ) async {
    final url = Uri.parse('$baseUrl/trees/import');
    final request = http.MultipartRequest('POST', url);
    final headers = await getHeaders();
    request.headers.addAll(headers);

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return jsonResponse['data'] as Map<String, dynamic>;
    }
    checkAuthError(response.statusCode);
    throw Exception('수목 데이터 가져오기 실패: ${response.body}');
  }
}
