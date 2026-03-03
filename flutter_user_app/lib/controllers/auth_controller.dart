import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  bool isLoading = false;
  bool isNewUser = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController entryCodeController = TextEditingController();

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('test_name') ?? '';
    phoneController.text = prefs.getString('test_phone') ?? '';
    emailController.text = prefs.getString('test_email') ?? '';
    entryCodeController.text = prefs.getString('test_entry_code') ?? '';
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_name', nameController.text.trim());
    await prefs.setString('test_phone', phoneController.text.trim());
    await prefs.setString('test_email', emailController.text.trim());
    await prefs.setString('test_entry_code', entryCodeController.text.trim());
  }

  Future<void> clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('test_name');
    await prefs.remove('test_phone');
    await prefs.remove('test_email');
    await prefs.remove('test_entry_code');
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    entryCodeController.clear();
  }

  Future<void> handleLogin({
    required GlobalKey<FormState> formKey,
    required VoidCallback onSuccess,
    required Function(String) onError,
    required VoidCallback onUpdate,
  }) async {
    if (!formKey.currentState!.validate()) return;

    await saveData();
    isLoading = true;
    onUpdate();

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final entryCode = entryCodeController.text.trim();

    try {
      final user = await SupabaseService.findUser(name, phone);

      if (user != null) {
        final isValid = await SupabaseService.isValidEntryCode(
          entryCode,
          user: user,
        );
        if (!isValid) {
          onError(
            '사용기간이 만료되었거나 입장코드가 올바르지 않습니다, 관리자 앱에서 코드를 확인하거나 관리자에게 문의 하세요.',
          );
          isLoading = false;
          onUpdate();
          return;
        }
        // Supabase 세션 생성 (API 호출용)
        await SupabaseService.signInAnonymously();
        onSuccess();
      } else {
        if (!isNewUser) {
          isNewUser = true;
          isLoading = false;
          onUpdate();
          onError('신규 사용자입니다. 이메일을 입력하여 등록을 완료해주세요.');
        } else {
          final email = emailController.text.trim();
          final isValid = await SupabaseService.isValidEntryCode(entryCode);
          if (!isValid) {
            onError('입장코드가 올바르지 않습니다. 관리자 앱의 설정화면에서 확인하세요.');
            isLoading = false;
            onUpdate();
            return;
          }

          await SupabaseService.registerUser(
            name: name,
            phone: phone,
            email: email,
            entryCode: entryCode,
          );

          // Supabase 세션 생성
          await SupabaseService.signInAnonymously();
          onSuccess();
        }
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('users_phone_key') ||
          errorMessage.contains('23505')) {
        errorMessage = '이미 등록된 번호입니다. 이름을 확인하시거나 기존 정보로 로그인해 주세요.';
      } else if (errorMessage.contains('anonymous_provider_disabled')) {
        errorMessage =
            '서버 설정 오류: Supabase 익명 로그인이 비활성화 상태입니다. 관리자 대시보드(Auth > Providers > Anonymous)에서 기능을 활성화해 주세요.';
      }
      debugPrint('Login Error: $e');
      onError(errorMessage);
      isLoading = false;
      onUpdate();
    }
  }

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    entryCodeController.dispose();
  }
}
