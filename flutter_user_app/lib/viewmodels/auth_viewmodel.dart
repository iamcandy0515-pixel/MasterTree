import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/supabase_service.dart';
import '../core/device_info_service.dart';
import '../core/config_service.dart';
import '../services/session_monitor_service.dart';
import 'auth_logic_handler.dart';
import 'auth_validator.dart';

class AuthViewModel extends ChangeNotifier with AuthLogicHandler, AuthValidator {
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
  bool get isNewUser => _isExistingUser == false;

  Future<void> initialize() async {
    await loadSavedData();
    _setupSessionMonitor();
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
      if (name.length >= 2 && phone.length >= 12) await _checkUserStatus(name, phone);
    });
  }

  Future<void> _checkUserStatus(String name, String phone) async {
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

  Future<void> handleLogin({
    required GlobalKey<FormState> formKey,
    required VoidCallback onSuccess,
    required Function(String) onError,
    bool forceLogout = false,
  }) async {
    if (formKey.currentState == null) {
      onError('시스템 오류: 폼 상태를 찾을 수 없습니다.');
      return;
    }
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

      final deviceInfo = await DeviceInfoService.getDeviceInfo();
      final String? deviceId = deviceInfo['uuid'];
      
      if (_isExistingUser == true) {
        final String status = user?['status']?.toString() ?? '';
        if (<String>['expired', 'denied', 'rejected'].contains(status)) throw 'status_denied';
        if (status != 'approved') throw 'status_pending';
        if (isLinkExpired(user)) throw 'status_expired';

        if (!await ConfigService.isValidEntryCode(entryCode, user: user)) throw '입장코드가 올바르지 않습니다.';
        
        await syncAuthAndUser(user!, name, phone,
          deviceId: deviceId,
          deviceModel: deviceInfo['model'],
          osVersion: deviceInfo['os'],
          forceLogout: forceLogout,
        );
      } else {
        if (!await ConfigService.isValidEntryCode(entryCode)) throw '입장코드가 올바르지 않습니다.';
        
        final authRes = await signUpOrSignIn(phone, name, email,
          deviceId: deviceId,
          deviceModel: deviceInfo['model'],
          osVersion: deviceInfo['os'],
        );
        
        if (authRes.user == null) throw '인증 계정 생성 또는 로그인에 실패했습니다.';

        final checkAgain = await checkExistingUser(name, phone);
        if (checkAgain == null) {
          await SupabaseService.registerUser(
            name: name, phone: phone, email: email, entryCode: entryCode, 
            authId: authRes.user!.id,
          );
          throw 'status_pending';
        }
      }
      
      await saveData();
      _setupSessionMonitor();
      onSuccess();
    } catch (e) {
      final msg = "$e";
      if (['status_denied', 'status_pending', 'status_expired'].contains(msg)) { 
        onError(msg); 
      } else if (msg.startsWith('ALREADY_LOGGED_IN:')) {
        onError(msg);
      } else { 
        onError(getErrorMessage(e)); 
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupSessionMonitor() {
    final session = SupabaseService.client.auth.currentSession;
    final user = SupabaseService.client.auth.currentUser;
    if (session != null && user != null) {
      SessionMonitorService.startMonitoring(
        authId: user.id,
        currentSessionId: session.accessToken,
        onLogoutRequired: () async {
          await SupabaseService.signOut();
          notifyListeners(); // Will trigger UI rebuild to LoginScreen
        },
      );
    }
  }

  @override
  void dispose() {
    SessionMonitorService.stopMonitoring();
    _debounceTimer?.cancel();
    nameController.dispose(); phoneController.dispose();
    emailController.dispose(); entryCodeController.dispose();
    super.dispose();
  }
}
