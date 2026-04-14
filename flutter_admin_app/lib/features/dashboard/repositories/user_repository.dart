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
    final String params = 'page=$page&limit=$limit${status != null ? '&status=$status' : ''}';
    final Uri url = Uri.parse('$_baseUrl/users?$params');
    
    final session = Supabase.instance.client.auth.currentSession;
    final String token = session?.accessToken ?? '';

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        final Map<String, dynamic> data = (jsonResponse['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final List<dynamic> users = (data['users'] as List<dynamic>?) ?? <dynamic>[];
        return users.map((dynamic u) => u as Map<String, dynamic>).toList();
      }
    }
    throw Exception('Failed to load users: ${response.statusCode}');
  }

  Future<void> updateUserStatus(String id, String status) async {
    final Uri url = Uri.parse('$_baseUrl/users/$id/status');
    final session = Supabase.instance.client.auth.currentSession;
    final String token = session?.accessToken ?? '';

    final http.Response response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user status: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> updateData) async {
    final Uri url = Uri.parse('$_baseUrl/users/$id');
    final session = Supabase.instance.client.auth.currentSession;
    final String token = session?.accessToken ?? '';

    final http.Response response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return (jsonResponse['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  Future<void> deleteUser(String id) async {
    final Uri url = Uri.parse('$_baseUrl/users/$id');
    final session = Supabase.instance.client.auth.currentSession;
    final String token = session?.accessToken ?? '';

    final http.Response response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }
}
