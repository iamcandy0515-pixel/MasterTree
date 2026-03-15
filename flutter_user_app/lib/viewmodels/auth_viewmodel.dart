import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/supabase_service.dart';
import 'auth_logic_handler.dart';

class AuthViewModel extends ChangeNotifier with AuthLogicHandler {
  bool _isLoading = false;
  bool _isCheckingServer = false;
  bool? _isExistingUser;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(text: '010-');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController entryCodeController = TextEditingController();

  Timer? _debounceTimer;

  bool get isLoading => _isLoading;
  bool get isCheckingServer => _isCheckingServer;
  bool? get isExistingUser => _isExistingUser;
  bool get showEmailField => _isExistingUser == false;

  Future<void> initialize() async => await loadSavedData();

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
      if (name.length >= 2 && phone.length >= 12) await checkUserStatus(name, phone);
    });
  }

  Future<void> checkUserStatus(String name, String phone) async {
    if (_isCheckingServer) return;
    _isCheckingServer = true;
    notifyListeners();
    try {
      final user = await checkExistingUser(name, phone);
      _isExistingUser = (user != null);
    } catch (e) {
      _isExistingUser = true;
    } finally {
      _isCheckingServer = false;
      notifyListeners();
    }
  }

  String? validateName(String? v) => (v == null || v.trim().isEmpty) ? '이름을 입력해주세요.' : (v.contains(' ') ? '이름에 공백을 포함할 수 없습니다.' : null);
  String? validatePhone(String? v) => (v == null || v.isEmpty) ? '휴대전화 번호를 입력해주세요.' : (RegExp(r'^010-\d{4}-\d{4}$').hasMatch(v) ? null : "010으로 시작하는 11자리 숫자를 입력해주세요.");
  String? validateEmail(String? v) => (!showEmailField) ? null : ((v == null || v.isEmpty) ? '이메일을 입력해주세요.' : (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v) ? null : '유효한 이메일 형식이 아닙니다.'));
  String? validateEntryCode(String? v) => (v == null || v.isEmpty) ? '입장코드를 입력해주세요.' : null;

  Future<void> handleLogin({required GlobalKey<FormState> formKey, required VoidCallback onSuccess, required Function(String) onError}) async {
    if (!formKey.currentState!.validate()) return;
    _isLoading = true;
    notifyListeners();
    try {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final entryCode = entryCodeController.text.trim();

      Map<String, dynamic>? user = await checkExistingUser(name, phone);
      _isExistingUser = (user != null);

      if (_isExistingUser == true) {
        final status = user?['status'];
        if (['expired', 'denied', 'rejected'].contains(status)) throw 'status_denied';
        if (status != 'approved') throw 'status_pending';
        if (isLinkExpired(user)) throw 'status_expired';

        if (!await SupabaseService.isValidEntryCode(entryCode, user: user)) throw '입장코드가 올바르지 않습니다.';
        await syncAuthAndUser(user!, name, phone);
      } else {
        if (!await SupabaseService.isValidEntryCode(entryCode)) throw '입장코드가 올바르지 않습니다.';
        final authRes = await signUpOrSignIn(phone, name, email);
        if (authRes.user == null) throw '인증 계정 생성 또는 로그인에 실패했습니다.';

        final checkAgain = await checkExistingUser(name, phone);
        if (checkAgain == null) {
          await SupabaseService.registerUser(name: name, phone: phone, email: email, entryCode: entryCode, authId: authRes.user!.id);
          throw 'status_pending';
        }
      }
      await saveData();
      onSuccess();
    } catch (e) {
      final msg = e.toString();
      if (['status_denied', 'status_pending', 'status_expired'].contains(msg)) { onError(msg); }
      else { onError(getErrorMessage(e)); }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    nameController.dispose(); phoneController.dispose();
    emailController.dispose(); entryCodeController.dispose();
    super.dispose();
  }
}
