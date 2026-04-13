import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_service.dart';

mixin AuthLogicHandler {
  Future<Map<String, dynamic>?> checkExistingUser(String name, String phone) async {
    return await SupabaseService.findUser(name, phone);
  }

  bool isLinkExpired(Map<String, dynamic>? user) {
    if (user?['expired_at'] != null) {
      try {
        final String expiredAtStr = "${user?['expired_at'] ?? ''}";
        final DateTime expiredAt = DateTime.parse(expiredAtStr);
        return DateTime.now().isAfter(expiredAt);
      } catch (e) {
        debugPrint('Expiration check error: $e');
      }
    }
    return false;
  }

  int? calculateRemainingDays(Map<String, dynamic>? user) {
    if (user?['expired_at'] == null) return null;
    try {
      final DateTime expiredAt = DateTime.parse(user!['expired_at'].toString()).toLocal();
      final DateTime now = DateTime.now();
      
      if (now.isAfter(expiredAt)) return -1; // Expired
      
      final Duration diff = expiredAt.difference(now);
      return diff.inDays;
    } catch (e) {
      debugPrint('Remaining days calculation error: $e');
      return null;
    }
  }

  String getErrorMessage(dynamic e) {
    if (e == null) return '알 수 없는 오류가 발생했습니다.';
    
    String errorMessage = "";
    if (e is AuthException) {
      errorMessage = "Auth Error: ${e.message} (${e.statusCode})";
    } else if (e is String) {
      errorMessage = e;
    } else {
      errorMessage = "$e";
    }
    
    if (errorMessage.contains('users_phone_key') || errorMessage.contains('23505')) {
      return '이미 등록된 번호입니다. 이름을 확인하시거나 기존 정보로 로그인해 주세요.';
    }
    return errorMessage;
  }

  Future<void> syncAuthAndUser(
    Map<String, dynamic> user,
    String name,
    String phone, {
    String? deviceId,
    String? deviceModel,
    String? osVersion,
    bool forceLogout = false,
  }) async {
    try {
      await SupabaseService.signInPermanent(
        phone: phone,
        deviceId: deviceId,
        deviceModel: deviceModel,
        osVersion: osVersion,
        forceLogout: forceLogout,
      );
    } on AuthException catch (e) {
      final String msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') || msg.contains('400')) {
        try {
          final authResponse = await SupabaseService.signUpPermanent(
            phone: phone,
            name: name,
            email: "${user['email'] ?? ''}",
          );
          if (authResponse.user != null) {
            await SupabaseService.updateUserAuthId(user['id'], authResponse.user!.id);
            // After sign up, sync session
            await SupabaseService.signInPermanent(
              phone: phone,
              deviceId: deviceId,
              deviceModel: deviceModel,
              osVersion: osVersion,
            );
          }
        } on AuthException catch (signUpErr) {
          if (signUpErr.message.toLowerCase().contains('already registered') || 
              signUpErr.message.toLowerCase().contains('user_already_exists')) {
            throw '인증 서버 계정이 이미 존재하지만 비번이 일치하지 않습니다. 관리자 콘솔에서 계정 삭제 후 재시도 바랍니다.';
          }
          rethrow;
        }
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signUpOrSignIn(
    String phone,
    String name,
    String email, {
    String? deviceId,
    String? deviceModel,
    String? osVersion,
  }) async {
    try {
      return await SupabaseService.signUpPermanent(phone: phone, name: name, email: email);
    } on AuthException catch (e) {
      final String msg = e.message.toLowerCase();
      if (msg.contains('already registered') || msg.contains('user_already_exists')) {
        try {
          return await SupabaseService.signInPermanent(
            phone: phone,
            deviceId: deviceId,
            deviceModel: deviceModel,
            osVersion: osVersion,
          );
        } on AuthException catch (signInErr) {
          final String sMsg = signInErr.message.toLowerCase();
          if (sMsg.contains('invalid login credentials') || sMsg.contains('400')) {
             throw '인증 서버 계정이 이미 존재하지만 비번이 일치하지 않습니다. 관리자 콘솔에서 계정 삭제 후 재시도 바랍니다.';
          }
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }
}
