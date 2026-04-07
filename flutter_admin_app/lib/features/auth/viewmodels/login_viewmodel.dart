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

      debugPrint('🔐 [LoginViewModel] Credentials loaded: Email=$_savedEmail');
    } catch (e) {
      debugPrint('❌ [LoginViewModel] Error loading credentials: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🚀 [LoginViewModel] Attempting login via Auth Proxy: $email');

      // Use Node API as a Proxy to bypass CORS
      final url = Uri.parse('${NodeApi.baseUrl}/users/login');
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final Map<String, dynamic>? responseData = data['data'] as Map<String, dynamic>?;
          final Map<String, dynamic>? session = responseData?['session'] as Map<String, dynamic>?;
          
          if (session != null) {
            final String refreshToken = (session['refresh_token'] as String?) ?? '';
            // Manually set the session in the local Supabase client using refresh_token
            await Supabase.instance.client.auth.setSession(refreshToken);
            
            // Save credentials locally
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('saved_email', email);
              await prefs.setString('saved_password', password);
              debugPrint('✅ [LoginViewModel] Login successful via Proxy & Session set.');
            } catch (e) {
              debugPrint('❌ [LoginViewModel] Error saving credentials: $e');
            }
            return true;
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
      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password required';
      }

      debugPrint('🚀 [LoginViewModel] Attempting signup with: $email');
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      debugPrint('❌ [LoginViewModel] Signup Auth Error: ${e.message}');
      throw e.message;
    } catch (e) {
      debugPrint('❌ [LoginViewModel] Signup Unexpected Error: $e');
      throw 'Signup failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
