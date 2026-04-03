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

  /// MEM (Manual Entry Mapping) - Force safe conversion for Minified JS Objects
  Map<String, dynamic> _forceCast(dynamic data) {
    if (data is! Map) return <String, dynamic>{};
    return data.map((k, v) => MapEntry(k.toString(), v));
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
        body: jsonEncode(<String, dynamic>{'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        
        // 🔥 [MEM] Manual entry mapping to survive minified 'mS' vs 'fR' crashes
        final Map<String, dynamic> data = _forceCast(decoded);
        
        if (data['success'] == true) {
          final Map<String, dynamic> rawData = _forceCast(data['data']);
          final Map<String, dynamic> session = _forceCast(rawData['session']);
          
          final dynamic accessToken = session['access_token'];
          
          if (accessToken != null) {
            final String tokenStr = accessToken.toString();
            
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('access_token', tokenStr);
              await prefs.setString('saved_email', email);
              await prefs.setString('saved_password', password);
            } catch (e) {
              debugPrint('❌ [LoginViewModel] Prefs error (DTC failure): $e');
              return false;
            }
            
            return true;
          }
        }
      }
      
      debugPrint('❌ [LoginViewModel] Login failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('❌ [LoginViewModel] CRASH: $e');
      return false; 
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
