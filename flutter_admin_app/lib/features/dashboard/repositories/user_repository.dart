import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/core/api/node_api.dart';

class UserRepository {
  final String _baseUrl;

  UserRepository()
    : _baseUrl = NodeApi.baseUrl;

  Future<List<Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 50,
    String? status,
  }) async {
    final queryParams =
        'page=$page&limit=$limit${status != null ? '&status=$status' : ''}';
    final url = Uri.parse('$_baseUrl/users?$queryParams');
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

  Future<void> updateUserStatus(String id, String status) async {
    final url = Uri.parse('$_baseUrl/users/$id/status');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user status: ${response.body}');
    }
  }

  Future<void> deleteUser(String id) async {
    final url = Uri.parse('$_baseUrl/users/$id');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }
}
