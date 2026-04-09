import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'constants.dart';

class ConfigService {
  /// Fetch the global/required entry code from the Admin API
  static Future<String> fetchGlobalEntryCode() async {
    final String url = '${AppConstants.apiUrl}/settings/entry-code';
    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic dataRaw = jsonDecode(utf8.decode(response.bodyBytes));
        final Map<String, dynamic> data = Map<String, dynamic>.from(dataRaw as Map);
        if (data['success'] == true) {
          final dynamic code = (data['data'] as Map<dynamic, dynamic>?)?['entryCode'];
          if (code != null) return code.toString();
        }
      }
    } catch (e) {
      debugPrint('Error fetching entry code: $e');
    }
    return '1133'; // Default fallback
  }

  /// Check if global/required entry code is valid
  static Future<bool> isValidEntryCode(String code, {Map<String, dynamic>? user}) async {
    // 1. If user object has specific entry_code, check it first
    if (user != null && user['entry_code'] != null) {
      if ("${user['entry_code'] ?? ''}" == code) return true;
    }
    
    // 2. Check against global code
    final serverCode = await fetchGlobalEntryCode();
    return serverCode == code;
  }
}
