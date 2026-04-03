import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_admin_app/core/api/node_api.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _savedEmail = '';
  String _savedPassword = '';

  bool get isLoading => _isLoading;
  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;

  Future<void> loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedEmail = prefs.getString('saved_email') ?? '';
      _savedPassword = prefs.getString('saved_password') ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [LoginViewModel] Error loading credentials: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🚀 [LoginViewModel] Attempting login via Auth Proxy: $email');

      final url = Uri.parse('${NodeApi.baseUrl}/users/login');
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
          if (data['success'] == true) {
            final dynamic rawData = data['data'];
            if (rawData is Map) {
              final Map<String, dynamic> sessionContainer = Map<String, dynamic>.from(rawData);
              final dynamic sessionData = sessionContainer['session'];
              if (sessionData is Map) {
                final Map<String, dynamic> session = Map<String, dynamic>.from(sessionData);
                final dynamic accessToken = session['access_token'];
                
                if (accessToken != null) {
                  final String tokenStr = accessToken.toString();
                  
                  // 🔥 [CRITICAL] Core Homing: Store token directly in SharedPreferences 👑
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('access_token', tokenStr);
                    await prefs.setString('saved_email', email);
                    await prefs.setString('saved_password', password);
                  } catch (e) {
                    debugPrint('❌ [LoginViewModel] Error saving to prefs: $e');
                  }

                  // [Supabase Sync Plan] Best effort sync, but proceed if successful proxy.
                  try {
                    // Try setting as refresh token if access fails in setSession? 
                    // Actually setSession in supabase_flutter can be token or session. 
                    await Supabase.instance.client.auth.setSession(tokenStr);
                  } catch (se) {
                    debugPrint('⚠️ [LoginViewModel] Supabase session sync warning (proceed anyway): $se');
                  }
                  
                  debugPrint('✅ [LoginViewModel] Login procedure complete via Direct Token Storage.');
                  return true;
                }
              }
            }
          }
        }
      }
      
      debugPrint('❌ [LoginViewModel] Login failed: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('❌ [LoginViewModel] Unexpected Error: $e');
      throw '인증 서버와의 통신에 실패했습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) throw 'Email and password required';
      await Supabase.instance.client.auth.signUp(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Signup failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
