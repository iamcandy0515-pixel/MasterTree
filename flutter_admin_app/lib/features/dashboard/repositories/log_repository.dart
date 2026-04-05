import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/api/node_api.dart';

class LogRepository {
  final String _baseUrl;

  LogRepository()
    : _baseUrl = NodeApi.baseUrl;

  Future<List<Map<String, dynamic>>> getLogs() async {
    final url = Uri.parse('$_baseUrl/system/logs');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    final response = await http.get(
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
        final List<dynamic> logs = (jsonResponse['data'] as List<dynamic>?) ?? <dynamic>[];
        return logs
            .map(
              (dynamic l) {
                final Map<String, dynamic> item = l as Map<String, dynamic>;
                return <String, dynamic>{
                  'time': item['time']?.toString() ?? '',
                  'type': item['type']?.toString() ?? 'unknown',
                  'msg': item['msg']?.toString() ?? '',
                  'color': _parseHexColor(item['color']?.toString() ?? '#FFFFFF'),
                };
              },
            )
            .toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> clearLogs() async {
    final url = Uri.parse('$_baseUrl/system/logs');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Color _parseHexColor(String hexStr) {
    hexStr = hexStr.replaceAll('#', '');
    if (hexStr.length == 6) {
      hexStr = 'FF$hexStr';
    } else if (hexStr.toLowerCase().startsWith('0x')) {
      return Color(int.parse(hexStr));
    }
    return Color(int.parse(hexStr, radix: 16));
  }
}
