import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class LogRepository {
  final String _baseUrl;

  LogRepository()
    : _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  Future<List<Map<String, dynamic>>> getLogs() async {
    final url = Uri.parse('$_baseUrl/system/logs');
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
        final logs = jsonResponse['data'] as List;
        return logs
            .map(
              (l) => {
                'time': l['time'],
                'type': l['type'],
                'msg': l['msg'],
                'color': _parseHexColor(l['color']),
              },
            )
            .toList();
      }
    }
    return [];
  }

  Future<void> clearLogs() async {
    final url = Uri.parse('$_baseUrl/system/logs');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    await http.delete(
      url,
      headers: {
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
