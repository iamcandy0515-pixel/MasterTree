import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      debugPrint('🚀 [LoginViewModel] Attempting login with: $email');

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Save credentials locally
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', email);
          await prefs.setString('saved_password', password);
          debugPrint('✅ [LoginViewModel] Credentials saved successfully.');
        } catch (e) {
          debugPrint('❌ [LoginViewModel] Error saving credentials: $e');
        }
        return true;
      }
      return false;
    } on AuthException catch (e) {
      debugPrint('❌ [LoginViewModel] Auth Error: ${e.message}');
      throw e.message;
    } catch (e) {
      debugPrint('❌ [LoginViewModel] Unexpected Error: $e');
      throw 'Unexpected error occurred';
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
