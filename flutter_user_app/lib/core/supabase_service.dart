import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static const String systemFixedPassword = 'admin1234';

  /// Performs email login (Permanent Account)
  static Future<AuthResponse> signInPermanent(String phone) async {
    final cleanPhone = phone.replaceAll('-', '');
    
    // 1. Check if user already has a specific email in public.users
    final existingUser = await client
        .from('users')
        .select('email')
        .eq('phone', cleanPhone)
        .maybeSingle();

    // 2. Priority: Registered Email -> Fallback: Virtual Email
    final targetEmail = existingUser?['email'] ?? 'u$cleanPhone@mastertree.app';

    return await client.auth.signInWithPassword(
      email: targetEmail,
      password: systemFixedPassword,
    );
  }

  /// Performs sign up (Permanent Account)
  static Future<AuthResponse> signUpPermanent(
    String phone, {
    required String name,
    required String email,
  }) async {
    final cleanPhone = phone.replaceAll('-', '');
    
    // Use the provided real email if available, otherwise fallback to virtual
    final targetEmail = (email.isNotEmpty && email.contains('@')) 
        ? email 
        : 'u$cleanPhone@mastertree.app';

    return await client.auth.signUp(
      email: targetEmail,
      password: systemFixedPassword,
      data: {
        'name': name,
        'user_email': email,
      },
    );
  }

  /// Get user status after sign in
  static Future<String> reloadUserStatus() async {
    final user = client.auth.currentUser;
    if (user == null) return 'none';

    // Fetch latest status from users table
    final response = await client
        .from('users')
        .select('status')
        .eq('auth_id', user.id)
        .maybeSingle();

    return response?['status'] ?? 'pending';
  }

  /// Get current session
  static Session? get currentSession => client.auth.currentSession;

  /// Check if user is logged in
  static bool get isLoggedIn => currentSession != null;

  /// Get list of trees from 'trees' table with main images
  static Future<List<Map<String, dynamic>>> getTrees() async {
    try {
      // Fetch all trees
      final treesResponse = await client.from('trees').select('*').order('name_kr');

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
      debugPrint('Error fetching trees: $e');
      rethrow;
    }
  }

  /// Check if user exists by name and phone
  static Future<Map<String, dynamic>?> findUser(
    String name,
    String phone,
  ) async {
    final cleanPhone = phone.replaceAll('-', '');
    // 1. Exact match check
    final response = await client
        .from('users')
        .select()
        .eq('name', name)
        .eq('phone', cleanPhone)
        .maybeSingle();

    // 3. Robustness check: if not found, check if the phone is already taken by someone else
    if (response == null) {
      final phoneCheck = await client
          .from('users')
          .select('id, name')
          .eq('phone', cleanPhone)
          .maybeSingle();

      if (phoneCheck != null) {
        throw '이미 해당 번호로 등록된 사용자가 있습니다. (등록된 이름: ${phoneCheck['name']})';
      }
    }

    return response;
  }

  /// Update user's auth_id after successful login
  static Future<void> updateUserAuthId(dynamic userId, String authId) async {
    try {
      await client.from('users').update({'auth_id': authId}).eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user auth_id: $e');
    }
  }

  /// Registered new user - returns the new user data
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    required String email,
    required String entryCode,
    String? authId,
  }) async {
    final cleanPhone = phone.replaceAll('-', '');
    return await client
        .from('users')
        .insert({
          'name': name,
          'phone': cleanPhone,
          'email': email,
          'entry_code': entryCode,
          'status': 'pending', // Always pending for new users
          'auth_id': authId,
        })
        .select()
        .single();
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
          final code = data['data']['entryCode'];
          if (code != null) return code;
        }
      } else {
        debugPrint('Failed to load entry code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching global entry code: $e');
    }
    // 기본값 1234를 제거하고 빈 값을 반환하여 실패 처리
    return '';
  }

  /// Check if global/required entry code is valid
  static Future<bool> isValidEntryCode(
    String code, {
    Map<String, dynamic>? user,
  }) async {
    final serverCode = await fetchGlobalEntryCode();
    // 서버에서 가져온 코드가 없거나(실패), 입력한 코드와 다르면 거부
    if (serverCode.isEmpty) return false;
    return serverCode == code;
  }
}
