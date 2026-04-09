import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static bool get isLoggedIn => client.auth.currentSession != null;

  static const String systemFixedPassword = 'admin1234';

  /// Performs email login (Permanent Account)
  static Future<AuthResponse> signInPermanent({
    required String phone,
    String? deviceId,
    String? deviceModel,
    String? osVersion,
    bool forceLogout = false,
  }) async {
    final String cleanPhone = phone.replaceAll('-', '');
    
    // 1. Check if user already has a specific email in public.users
    final Map<String, dynamic>? existingUserRaw = await client
        .from('users')
        .select<PostgrestMap?>('id, email, last_device_id, last_device_model')
        .eq('phone', cleanPhone)
        .maybeSingle();

    final Map<String, dynamic>? existingUser = (existingUserRaw != null) 
        ? Map<String, dynamic>.from(existingUserRaw) 
        : null;

    if (existingUser != null && deviceId != null && !forceLogout) {
      final dynamic lastDeviceId = existingUser['last_device_id'];
      if (lastDeviceId != null && lastDeviceId.toString() != deviceId.toString()) {
        final String model = "${existingUser['last_device_model'] ?? '다른 기기'}";
        throw 'ALREADY_LOGGED_IN:$model';
      }
    }

    // 2. Priority: Registered Email -> Fallback: Virtual Email
    final dynamic targetEmailRaw = existingUser != null ? existingUser['email'] : null;
    final String targetEmail = (targetEmailRaw != null && targetEmailRaw.toString().isNotEmpty) 
        ? targetEmailRaw.toString() 
        : 'u$cleanPhone@mastertree.app';

    final AuthResponse response = await client.auth.signInWithPassword(
      email: targetEmail,
      password: systemFixedPassword,
    );

    // 3. Register/Update Session in DB
    if (response.user != null) {
      final String accessToken = response.session?.accessToken ?? "";
      final String shortSessionId = accessToken.length > 20 ? accessToken.substring(0, 20) : "short_session";

      await client.from('users').update(<String, dynamic>{
        'last_device_id': deviceId,
        'last_device_model': deviceModel,
        'last_os_version': osVersion,
        'last_session_id': shortSessionId,
        'last_login_at': DateTime.now().toIso8601String(),
      }).eq('phone', cleanPhone);
    }

    return response;
  }

  /// Performs sign up (Permanent Account)
  static Future<AuthResponse> signUpPermanent({
    required String phone,
    required String name,
    String email = "",
  }) async {
    final String cleanPhone = phone.replaceAll('-', '');
    final String targetEmail = (email.isNotEmpty && email.contains('@')) 
        ? email 
        : 'u$cleanPhone@mastertree.app';

    return await client.auth.signUp(
      email: targetEmail,
      password: systemFixedPassword,
      data: <String, dynamic>{
        'name': name,
        'user_email': email,
      },
    );
  }

  /// Registered new user - returns the new user data
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    required String email,
    required String entryCode,
    String? authId,
  }) async {
    final String cleanPhone = phone.replaceAll('-', '');
    final Map<String, dynamic> response = await client
        .from('users')
        .insert(<String, dynamic>{
          'name': name,
          'phone': cleanPhone,
          'email': email,
          'entry_code': entryCode,
          'status': 'pending', 
          'auth_id': authId,
        })
        .select<PostgrestMap>('*')
        .single();
    
    return response;
  }

  /// Logout current session
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Returns localized error messages
  static String mapAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return '휴대폰 번호 또는 이름 정보가 올바르지 않습니다.';
    }
    return error;
  }

  /// Fetch all active trees
  static Future<List<Map<String, dynamic>>> fetchActiveTrees() async {
    try {
      final List<dynamic> response = await client
          .from('trees')
          .select<PostgrestList>('*')
          .eq('is_active', true)
          .order('order_index', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching trees: $e');
      return [];
    }
  }

  /// Check if user exists by name and phone
  static Future<Map<String, dynamic>?> findUser(String name, String phone) async {
    final String cleanPhone = phone.replaceAll('-', '');
    final Map<String, dynamic>? response = await client
        .from('users')
        .select<PostgrestMap?>('*')
        .eq('name', name)
        .eq('phone', cleanPhone)
        .maybeSingle();

    if (response == null) {
      final Map<String, dynamic>? phoneCheck = await client
          .from('users')
          .select<PostgrestMap?>('id, name')
          .eq('phone', cleanPhone)
          .maybeSingle();

      if (phoneCheck != null) {
        final String existingName = "${phoneCheck['name'] ?? '알 수 없음'}";
        throw '이미 해당 번호로 등록된 사용자가 있습니다. (등록된 이름: $existingName)';
      }
    }
    return response;
  }

  /// Update user's auth_id after successful login
  static Future<void> updateUserAuthId(dynamic userId, String authId) async {
    try {
      await client.from('users').update(<String, dynamic>{'auth_id': authId}).eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user auth_id: $e');
    }
  }

  /// Device Info Helper - Returns Map with uuid, model, os
  static Future<Map<String, String>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String model = 'Unknown';
    String os = 'Unknown';
    String uuid = 'Unknown';

    try {
      if (kIsWeb) {
        final web = await deviceInfo.webBrowserInfo;
        model = "${web.browserName.name}";
        os = 'Web';
        uuid = 'web-${web.userAgent ?? 'Unknown-Web-ID'}';
      } else if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        model = "${android.model}";
        os = "Android ${android.version.release}";
        uuid = "${android.id}";
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        model = "${ios.name}";
        os = "iOS ${ios.systemVersion}";
        uuid = "${ios.identifierForVendor ?? 'Unknown-iOS-ID'}";
      }
    } catch (e) {
      debugPrint('--- DEVICE_INFO_ERROR: $e');
    }

    return {'model': model, 'os': os, 'uuid': uuid};
  }

  /// Re-fetches the user status from public.users to ensure synchronization
  static Future<String> reloadUserStatus() async {
    final user = client.auth.currentUser;
    if (user == null) return 'pending';

    try {
      final Map<String, dynamic>? data = await client
          .from('users')
          .select<PostgrestMap?>('status')
          .eq('auth_id', user.id)
          .maybeSingle();
      
      return data?['status']?.toString() ?? 'pending';
    } catch (e) {
      debugPrint('Error reloading user status: $e');
      return 'pending';
    }
  }

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
          if (code != null) return "$code";
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
      if (user['entry_code'].toString() == code) return true;
    }
    
    // 2. Check against global code
    final serverCode = await fetchGlobalEntryCode();
    return serverCode == code;
  }
}
