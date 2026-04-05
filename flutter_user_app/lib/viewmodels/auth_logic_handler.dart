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
        final expiredAt = DateTime.parse(user!['expired_at']);
        return DateTime.now().isAfter(expiredAt);
      } catch (e) {
        debugPrint('Expiration check error: $e');
      }
    }
    return false;
  }

  String getErrorMessage(dynamic e) {
    String errorMessage = e.toString();
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
        phone,
        deviceId: deviceId,
        deviceModel: deviceModel,
        osVersion: osVersion,
        forceLogout: forceLogout,
      );
    } on AuthException catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('invalid_credentials') || errStr.contains('400')) {
        try {
          final authResponse = await SupabaseService.signUpPermanent(
            phone,
            name: name,
            email: user['email'] ?? '',
          );
          if (authResponse.user != null) {
            await SupabaseService.updateUserAuthId(user['id'], authResponse.user!.id);
            // After sign up, sync session as well
            await SupabaseService.signInPermanent(
              phone,
              deviceId: deviceId,
              deviceModel: deviceModel,
              osVersion: osVersion,
            );
          }
        } on AuthException catch (signUpErr) {
          if (signUpErr.message.toLowerCase().contains('already registered') || signUpErr.message.toLowerCase().contains('user_already_exists')) {
            throw '인증 서버에 계정이 이미 존재하지만 비번이 일치하지 않습니다. 관리자 콘솔에서 해당 이메일/번호의 계정을 삭제 후 다시 시도해주세요.';
          }
          rethrow;
        }
      } else {
        rethrow;
      }
    } catch (e) {
      // Re-throw custom error string from SupabaseService
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
      return await SupabaseService.signUpPermanent(phone, name: name, email: email);
    } on AuthException catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('already registered') || errStr.contains('user_already_exists')) {
        try {
          return await SupabaseService.signInPermanent(
            phone,
            deviceId: deviceId,
            deviceModel: deviceModel,
            osVersion: osVersion,
          );
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
  }
}
