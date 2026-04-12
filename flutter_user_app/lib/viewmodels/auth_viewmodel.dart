import 'dart:async';
import 'package:flutter/material.dart';
import '../core/supabase_service.dart';
import '../core/device_info_service.dart';
import '../core/config_service.dart';
import '../services/session_monitor_service.dart';
import 'auth_logic_handler.dart';
import 'auth_validator.dart';
import 'auth_persistence_handler.dart';

class AuthViewModel extends ChangeNotifier with AuthLogicHandler, AuthValidator, AuthPersistenceHandler {
  /// Adheres to DEVELOPMENT_RULES.md (Rule 1-1, < 200 lines).
  
  bool _isLoading = false;
  bool _isCheckingServer = false;
  bool? _isExistingUser;
  String _userStatus = 'pending'; // 'approved', 'expired', 'pending'

  Timer? _debounceTimer;

  bool get isLoading => _isLoading;
  bool get isCheckingServer => _isCheckingServer;
  bool? get isExistingUser => _isExistingUser;
  bool get isNewUser => _isExistingUser == false;
  String get userStatus => _userStatus;

  Future<void> initialize() async {
    await loadSavedData(onUserStatusLoaded: (status) => _isExistingUser = status);
    await checkSessionStatus();
    _setupSessionMonitor();
  }

  Future<void> checkSessionStatus() async {
    _userStatus = await SupabaseService.reloadUserStatus();
    if (_userStatus == 'expired') _isExistingUser = null;
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
    if (formKey.currentState == null || !formKey.currentState!.validate()) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final entryCode = entryCodeController.text.trim();

      Map<String, dynamic>? user = await checkExistingUser(name, phone);
      _isExistingUser = (user != null);

      if (!await ConfigService.isValidEntryCode(entryCode)) {
        final currentCode = await ConfigService.fetchGlobalEntryCode();
        throw "입장코드가 '$currentCode' 으로 변경되었습니다. 코드를 수정해 주세요.";
      }

      final deviceInfo = await DeviceInfoService.getDeviceInfo();
      if (_isExistingUser == true) {
        final String status = user?['status']?.toString() ?? '';
        if (<String>['expired', 'denied', 'rejected'].contains(status)) throw 'status_denied';
        if (status != 'approved') throw 'status_pending';
        if (isLinkExpired(user)) throw 'status_expired';

        await syncAuthAndUser(user!, name, phone, deviceId: deviceInfo['uuid'],
          deviceModel: deviceInfo['model'], osVersion: deviceInfo['os'], forceLogout: forceLogout);
      } else {
        final authRes = await signUpOrSignIn(phone, name, emailController.text.trim(),
          deviceId: deviceInfo['uuid'], deviceModel: deviceInfo['model'], osVersion: deviceInfo['os']);
        
        final checkAgain = await checkExistingUser(name, phone);
        if (checkAgain == null) {
          await SupabaseService.registerUser(name: name, phone: phone, 
            email: emailController.text.trim(), entryCode: entryCode, authId: authRes.user!.id);
          throw 'status_pending';
        }
      }
      
      await saveData(_isExistingUser);
      _setupSessionMonitor();
      onSuccess();
    } catch (e) {
      final msg = "$e";
      if (['status_denied', 'status_pending', 'status_expired'].contains(msg) || msg.startsWith('ALREADY_LOGGED_IN:')) {
        onError(msg);
      } else {
        onError(getErrorMessage(e));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleLogout() async {
    SessionMonitorService.stopMonitoring();
    await SupabaseService.signOut();
    await clearSavedData();
    _isExistingUser = null;
    notifyListeners();
  }

  void _setupSessionMonitor() {
    final session = SupabaseService.client.auth.currentSession;
    final user = SupabaseService.client.auth.currentUser;
    if (session != null && user != null) {
      SessionMonitorService.startMonitoring(authId: user.id, currentSessionId: session.accessToken,
        onLogoutRequired: () async { await SupabaseService.signOut(); notifyListeners(); });
    }
  }

  @override
  void dispose() {
    SessionMonitorService.stopMonitoring();
    _debounceTimer?.cancel();
    disposeControllers();
    super.dispose();
  }
}
