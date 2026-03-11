import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  bool isLoading = false;
  bool isCheckingServer = false;
  bool? isExistingUser; // null: unknown, true: existing, false: new

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController entryCodeController = TextEditingController();

  Timer? _debounceTimer;

  bool get showEmailField => isExistingUser == false;

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('test_name') ?? '';
    phoneController.text = prefs.getString('test_phone') ?? '';
    emailController.text = prefs.getString('test_email') ?? '';
    entryCodeController.text = prefs.getString('test_entry_code') ?? '';

    // If we have saved data, assume existing user to hide email field initially
    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
      isExistingUser = prefs.getBool('is_existing_user') ?? true;
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_name', nameController.text.trim());
    await prefs.setString('test_phone', phoneController.text.trim());
    await prefs.setString('test_email', emailController.text.trim());
    await prefs.setString('test_entry_code', entryCodeController.text.trim());
    await prefs.setBool('is_existing_user', isExistingUser ?? false);
  }

  Future<void> clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    entryCodeController.clear();
    isExistingUser = null;
  }

  /// Debounced user existence check
  void onInputChanged(VoidCallback onUpdate) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();

      if (name.length >= 2 && phone.length >= 12) {
        await checkUserStatus(name, phone, onUpdate);
      }
    });
  }

  Future<void> checkUserStatus(
    String name,
    String phone,
    VoidCallback onUpdate,
  ) async {
    if (isCheckingServer) return;

    isCheckingServer = true;
    onUpdate();

    try {
      final user = await SupabaseService.findUser(name, phone);
      isExistingUser = (user != null);
    } catch (e) {
      // If error (e.g. phone taken by other name), we treat as existing to show error later
      isExistingUser = true;
    } finally {
      isCheckingServer = false;
      onUpdate();
    }
  }

  Future<void> handleLogin({
    required GlobalKey<FormState> formKey,
    required VoidCallback onSuccess,
    required Function(String) onError,
    required VoidCallback onUpdate,
  }) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    onUpdate();

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final entryCode = entryCodeController.text.trim();

    try {
      // Re-verify user existence if state is still unknown or we want to be sure
      Map<String, dynamic>? user = await SupabaseService.findUser(name, phone);
      isExistingUser = (user != null);

      if (isExistingUser == true) {
        // [Existing User Flow]
        final isValid = await SupabaseService.isValidEntryCode(
          entryCode,
          user: user,
        );
        if (!isValid) {
          onError('사용기간이 만료되었거나 입장코드가 올바르지 않습니다.');
          isLoading = false;
          onUpdate();
          return;
        }
      } else {
        // [New User Flow]
        final isValid = await SupabaseService.isValidEntryCode(entryCode);
        if (!isValid) {
          onError('입장코드가 올바르지 않습니다.');
          isLoading = false;
          onUpdate();
          return;
        }

        user = await SupabaseService.registerUser(
          name: name,
          phone: phone,
          email: email,
          entryCode: entryCode,
        );
      }

      // Finalize: Save data locally and sign in
      await saveData();
      final authResponse = await SupabaseService.signInAnonymously();
      
      // Sync Auth ID to users table for accurate tracking (Anonymous Session ID <-> User Name)
      if (authResponse.user != null && user != null) {
        await SupabaseService.updateUserAuthId(user['id'], authResponse.user!.id);
      }
      
      onSuccess();
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('users_phone_key') ||
          errorMessage.contains('23505')) {
        errorMessage = '이미 등록된 번호입니다. 이름을 확인하시거나 기존 정보로 로그인해 주세요.';
      }
      debugPrint('Login Error: $e');
      onError(errorMessage);
    } finally {
      isLoading = false;
      onUpdate();
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    entryCodeController.dispose();
  }
}

