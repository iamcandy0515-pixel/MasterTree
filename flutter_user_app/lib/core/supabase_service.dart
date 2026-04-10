import 'package:supabase_flutter/supabase_flutter.dart';

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
      if (lastDeviceId != null && lastDeviceId != deviceId) {
        final String model = existingUser['last_device_model']?.toString() ?? '다른 기기';
        throw 'ALREADY_LOGGED_IN:$model';
      }
    }
    // 2. Priority: Registered Email -> Fallback: Virtual Email
    final dynamic targetEmailRaw = existingUser != null ? existingUser['email'] : null;
    final String targetEmail = (targetEmailRaw != null && "$targetEmailRaw".isNotEmpty) 
        ? "$targetEmailRaw" 
        : 'u$cleanPhone@mastertree.app';

    final AuthResponse response = await client.auth.signInWithPassword(
      email: targetEmail,
      password: systemFixedPassword,
    );

    // 3. Register/Update Session in DB
    if (response.user != null) {
      final String accessToken = response.session?.accessToken ?? "";
      // 안전한 Substring 처리
      final String shortSessionId = accessToken.length > 20 
          ? accessToken.substring(0, 20) 
          : (accessToken.isNotEmpty ? accessToken : "no_token");

      await client.from('users').update(<String, dynamic>{
        'last_device_id': deviceId,
        'last_device_model': deviceModel,
        'last_os_version': osVersion,
        'last_session_id': shortSessionId,
        'last_login': DateTime.now().toIso8601String(),
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
    final List<dynamic> response = await client
        .from('trees')
        .select<PostgrestList>('*')
        .eq('is_active', true)
        .order('order_index', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
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
        final String existingName = phoneCheck['name']?.toString() ?? '알 수 없음';
        throw '이미 해당 번호로 등록된 사용자가 있습니다. (등록된 이름: $existingName)';
      }
    }
    return response;
  }

  /// Update user's auth_id after successful login
  static Future<void> updateUserAuthId(dynamic userId, String authId) async {
    await client.from('users').update(<String, dynamic>{'auth_id': authId}).eq('id', userId);
  }

  /// Re-fetches the user status and session validity from public.users
  static Future<String> reloadUserStatus() async {
    final user = client.auth.currentUser;
    if (user == null) return 'pending';

    final Map<String, dynamic>? data = await client
        .from('users')
        .select<PostgrestMap?>('status, last_session_id')
        .eq('auth_id', user.id)
        .maybeSingle();
    
    if (data == null) return 'pending';

    // Session Conflict Check: If current session token start doesn't match last_session_id in DB
    final session = client.auth.currentSession;
    if (session != null) {
      final String currentToken = session.accessToken;
      final String shortId = currentToken.length > 20 ? currentToken.substring(0, 20) : "short_session";
      final String? dbSessionId = data['last_session_id']?.toString();
      
      if (dbSessionId != null && dbSessionId != shortId) {
        // Someone else logged in! Force sign out.
        await signOut();
        return 'expired';
      }
    }
    
    final dynamic statusRaw = data['status'];
    return statusRaw?.toString() ?? 'pending';
  }
}
