import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isCheckingServer = false;
  bool? _isExistingUser; // null: unknown, true: existing, false: new

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(text: '010-');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController entryCodeController = TextEditingController();

  Timer? _debounceTimer;

  // Getters
  bool get isLoading => _isLoading;
  bool get isCheckingServer => _isCheckingServer;
  bool? get isExistingUser => _isExistingUser;
  bool get showEmailField => _isExistingUser == false;

  Future<void> initialize() async {
    await loadSavedData();
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('test_name') ?? '';
    phoneController.text = prefs.getString('test_phone') ?? '010-';
    emailController.text = prefs.getString('test_email') ?? '';
    entryCodeController.text = prefs.getString('test_entry_code') ?? '';

    if (nameController.text.isNotEmpty && phoneController.text.length >= 12) {
      _isExistingUser = prefs.getBool('is_existing_user') ?? true;
    }
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_name', nameController.text.trim());
    await prefs.setString('test_phone', phoneController.text.trim());
    await prefs.setString('test_email', emailController.text.trim());
    await prefs.setString('test_entry_code', entryCodeController.text.trim());
    await prefs.setBool('is_existing_user', _isExistingUser ?? false);
  }

  Future<void> clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    nameController.clear();
    phoneController.text = '010-';
    emailController.clear();
    entryCodeController.clear();
    _isExistingUser = null;
    notifyListeners();
  }

  void onInputChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();

      if (name.length >= 2 && phone.length >= 12) {
        await checkUserStatus(name, phone);
      }
    });
  }

  Future<void> checkUserStatus(String name, String phone) async {
    if (_isCheckingServer) return;

    _isCheckingServer = true;
    notifyListeners();

    try {
      final user = await SupabaseService.findUser(name, phone);
      _isExistingUser = (user != null);
    } catch (e) {
      _isExistingUser = true;
    } finally {
      _isCheckingServer = false;
      notifyListeners();
    }
  }

  // Validations
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return '이름을 입력해주세요.';
    if (value.contains(' ')) return '이름에 공백을 포함할 수 없습니다.';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return '휴대전화 번호를 입력해주세요.';
    final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return "010으로 시작하는 11자리 숫자를 입력해주세요.";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (!showEmailField) return null;
    if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '유효한 이메일 형식이 아닙니다.';
    }
    return null;
  }

  String? validateEntryCode(String? value) {
    if (value == null || value.isEmpty) return '입장코드를 입력해주세요.';
    return null;
  }

  Future<void> handleLogin({
    required GlobalKey<FormState> formKey,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final entryCode = entryCodeController.text.trim();

    try {
      Map<String, dynamic>? user = await SupabaseService.findUser(name, phone);
      _isExistingUser = (user != null);

      if (_isExistingUser == true) {
        final status = user?['status'];
        if (status == 'expired' || status == 'denied' || status == 'rejected') {
          onError('status_denied');
          _isLoading = false;
          notifyListeners();
          return;
        }

        if (status != 'approved') {
          onError('status_pending');
          _isLoading = false;
          notifyListeners();
          return;
        }

        if (user?['expired_at'] != null) {
          try {
            final expiredAt = DateTime.parse(user!['expired_at']);
            if (DateTime.now().isAfter(expiredAt)) {
              onError('status_expired');
              _isLoading = false;
              notifyListeners();
              return;
            }
          } catch (e) {
            debugPrint('Expiration check error: $e');
          }
        }

        final isValid = await SupabaseService.isValidEntryCode(entryCode, user: user);
        if (!isValid) {
          onError('입장코드가 올바르지 않습니다.');
          _isLoading = false;
          notifyListeners();
          return;
        }

        try {
          await SupabaseService.signInPermanent(phone);
        } on AuthException catch (e) {
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('invalid_credentials') || errStr.contains('400')) {
            try {
              final userData = user!;
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
                throw '인증 서버에 계정이 이미 존재하지만 비번이 일치하지 않습니다. 관리자 콘솔에서 해당 이메일/번호의 계정을 삭제 후 다시 시도해주세요.';
              }
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      } else {
        final isValid = await SupabaseService.isValidEntryCode(entryCode);
        if (!isValid) {
          onError('입장코드가 올바르지 않습니다.');
          _isLoading = false;
          notifyListeners();
          return;
        }

        AuthResponse? authResponse;
        try {
          authResponse = await SupabaseService.signUpPermanent(phone, name: name, email: email);
        } on AuthException catch (e) {
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('already registered') || e.code == 'user_already_exists') {
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
        if (authUser == null) throw '인증 계정 생성 또는 로그인에 실패했습니다.';

        final checkAgain = await SupabaseService.findUser(name, phone);
        if (checkAgain == null) {
          user = await SupabaseService.registerUser(
            name: name,
            phone: phone,
            email: email,
            entryCode: entryCode,
            authId: authUser.id,
          );
          onError('status_pending');
          _isLoading = false;
          notifyListeners();
          return;
        } else {
          user = checkAgain;
        }
      }

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
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    entryCodeController.dispose();
    super.dispose();
  }
}
