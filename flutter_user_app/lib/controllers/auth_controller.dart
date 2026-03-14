import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  bool isLoading = false;
  bool isCheckingServer = false;
  bool? isExistingUser; // null: unknown, true: existing, false: new

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(text: '010-');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController entryCodeController = TextEditingController();

  Timer? _debounceTimer;

  bool get showEmailField => isExistingUser == false;

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('test_name') ?? '';
    phoneController.text = prefs.getString('test_phone') ?? '010-';
    emailController.text = prefs.getString('test_email') ?? '';
    entryCodeController.text = prefs.getString('test_entry_code') ?? '';

    // If we have saved data, assume existing user to hide email field initially
    if (nameController.text.isNotEmpty && phoneController.text.length >= 12) {
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
    phoneController.text = '010-';
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

        // 1. Check status (if expired or denied)
        final status = user?['status'];
        if (status == 'expired' || status == 'denied' || status == 'rejected') {
          onError('status_denied'); // Special error code for UI
          isLoading = false;
          onUpdate();
          return;
        }

        // 1-1. Check for pending approval
        if (status != 'approved') {
          onError('status_pending'); // Special error code for Refresh UI
          isLoading = false;
          onUpdate();
          return;
        }

        // 2. Check personal expiration date if exists
        if (user?['expired_at'] != null) {
          try {
            final expiredAt = DateTime.parse(user!['expired_at']);
            if (DateTime.now().isAfter(expiredAt)) {
              onError('status_expired');
              isLoading = false;
              onUpdate();
              return;
            }
          } catch (e) {
            debugPrint('Expiration check error: $e');
          }
        }

        final isValid = await SupabaseService.isValidEntryCode(
          entryCode,
          user: user,
        );
        if (!isValid) {
          onError('입장코드가 올바르지 않습니다.');
          isLoading = false;
          onUpdate();
          return;
        }

        // 3. Log in or Migrate to permanent account
        try {
          await SupabaseService.signInPermanent(phone);
        } on AuthException catch (e) {
          // If login fails (not yet migrated from anonymous to permanent), try signing up
          // Or if it's already registered but somehow password mismatch, handle it
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('invalid_credentials') || errStr.contains('400')) {
            try {
              final userData = user!; // Already checked isExistingUser == true
              final authResponse = await SupabaseService.signUpPermanent(
                phone,
                name: name,
                email: userData['email'] ?? '',
              );
              if (authResponse.user != null) {
                await SupabaseService.updateUserAuthId(userData['id'], authResponse.user!.id);
              }
            } on AuthException catch (signUpErr) {
              if (signUpErr.message.contains('already registered') || signUpErr.code == 'user_already_exists') {
                // If even sign up says already registered, but sign in failed...
                // This means the password in Auth is different from our system fixed password.
                throw '인증 서버에 계정이 이미 존재하지만 비번이 일치하지 않습니다. 관리자 콘솔에서 해당 이메일/번호의 계정을 삭제 후 다시 시도해주세요.';
              }
              rethrow;
            }
          } else {
            rethrow;
          }
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

        // 1. Create permanent account in Auth first
        AuthResponse? authResponse;
        try {
          authResponse = await SupabaseService.signUpPermanent(
            phone,
            name: name,
            email: email,
          );
        } on AuthException catch (e) {
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('already registered') || e.code == 'user_already_exists') {
            // If already registered in Auth but not found in users table (or mismatch)
            // Try to sign in instead
            try {
              authResponse = await SupabaseService.signInPermanent(phone);
            } on AuthException catch (signInErr) {
              final sErrStr = signInErr.toString().toLowerCase();
              if (sErrStr.contains('invalid_credentials') || sErrStr.contains('400')) {
                 throw '인증 서버에 계정이 이미 존재하지만 비번이 일치하지 않습니다. 관리자 콘솔에서 해당 이메일/번호의 계정을 삭제 후 다시 시도해주세요.';
              }
              rethrow;
            }
          } else {
            rethrow;
          }
        }

        final authUser = authResponse.user;
        if (authUser == null) {
          throw '인증 계정 생성 또는 로그인에 실패했습니다.';
        }

        // 2. Register in users table if not already there (status: pending)
        // Check finding again after potential Auth change
        final checkAgain = await SupabaseService.findUser(name, phone);
        if (checkAgain == null) {
          user = await SupabaseService.registerUser(
            name: name,
            phone: phone,
            email: email,
            entryCode: entryCode,
            authId: authUser.id,
          );
          onError('status_pending'); // Redirect to pending notice
          isLoading = false;
          onUpdate();
          return;
        } else {
          // If suddenly found after Auth sync, just proceed to success flow
          user = checkAgain;
        }
      }

      // Finalize: Save data locally
      await saveData();
      onSuccess();
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('users_phone_key') || errorMessage.contains('23505')) {
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

