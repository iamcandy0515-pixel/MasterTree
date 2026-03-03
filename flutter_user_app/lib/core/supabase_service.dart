import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Performs anonymous login (Sign in Anonymously)
  static Future<AuthResponse> signInAnonymously() async {
    return await client.auth.signInAnonymously();
  }

  /// Get current session
  static Session? get currentSession => client.auth.currentSession;

  /// Check if user is logged in
  static bool get isLoggedIn => currentSession != null;

  /// Get list of trees from 'trees' table with main images
  static Future<List<Map<String, dynamic>>> getTrees() async {
    try {
      // Fetch all trees
      final treesResponse = await client
          .from('trees')
          .select('*')
          .order('name_kr');

      final trees = List<Map<String, dynamic>>.from(treesResponse);

      // Fetch main images for all trees
      for (var tree in trees) {
        final imageResponse = await client
            .from('tree_images')
            .select('image_url')
            .eq('tree_id', tree['id'])
            .eq('image_type', 'main')
            .maybeSingle();

        if (imageResponse != null && imageResponse['image_url'] != null) {
          tree['image_url'] = imageResponse['image_url'];
        }
      }

      return trees;
    } catch (e) {
      print('Error fetching trees: $e');
      rethrow;
    }
  }

  /// Check if user exists by name and phone
  static Future<Map<String, dynamic>?> findUser(
    String name,
    String phone,
  ) async {
    // 1. Exact match check
    final response = await client
        .from('users')
        .select()
        .eq('name', name)
        .eq('phone', phone)
        .maybeSingle();

    // 3. Robustness check: if not found, check if the phone is already taken by someone else
    if (response == null) {
      final phoneCheck = await client
          .from('users')
          .select('id, name')
          .eq('phone', phone)
          .maybeSingle();

      if (phoneCheck != null) {
        throw '이미 해당 번호로 등록된 사용자가 있습니다. (등록된 이름: ${phoneCheck['name']})';
      }
    }

    return response;
  }

  /// Registered new user
  static Future<void> registerUser({
    required String name,
    required String phone,
    required String email,
    required String entryCode,
  }) async {
    await client.from('users').insert({
      'name': name,
      'phone': phone,
      'email': email,
      'entry_code': entryCode,
      'status': 'approved', // Assuming default approved for simplicity
    });
  }

  /// Fetch the global/required entry code from the Admin API
  static Future<String> fetchGlobalEntryCode() async {
    final url = '${AppConstants.apiUrl}/settings/entry-code';
    try {
      debugPrint('Fetching entry code from: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('Response Data: $data');
        if (data['success'] == true) {
          return data['data']['entryCode'] ?? '1004';
        }
      } else {
        debugPrint('Failed to load entry code: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching global entry code from $url: $e');
    }
    return '1004'; // Default fallback changed to 1004 to distinguish from manual 1234
  }

  /// Check if global/required entry code is valid
  static Future<bool> isValidEntryCode(
    String code, {
    Map<String, dynamic>? user,
  }) async {
    final serverCode = await fetchGlobalEntryCode();
    // Allow if it matches either the global server code OR the specific user's code
    if (serverCode == code) return true;
    if (user != null && user['entry_code'] == code) return true;
    return false;
  }
}
