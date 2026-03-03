import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final String _baseUrl;

  UserRepository()
    : _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  Future<List<Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 50,
  }) async {
    final url = Uri.parse('$_baseUrl/users?page=$page&limit=$limit');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        final data = jsonResponse['data'];
        final users = data['users'] as List;
        return users.map((u) => u as Map<String, dynamic>).toList();
      }
    }
    throw Exception('Failed to load users: ${response.body}');
  }
}
