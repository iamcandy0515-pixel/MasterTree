import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceInfoService {
  static const String _webUuidKey = 'WEB_DEVICE_UUID';

  /// Device Info Helper - Returns Map with uuid, model, os
  /// Safe for both Mobile and Web
  static Future<Map<String, String>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String model = 'Unknown';
    String os = 'Unknown';
    String uuid = 'Unknown';

    try {
      if (kIsWeb) {
        final WebBrowserInfo web = await deviceInfo.webBrowserInfo;
        model = web.browserName.name;
        os = 'Web';
        
        // Web: Persistent UUID using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String? savedUuid = prefs.getString(_webUuidKey);
        
        if (savedUuid == null || savedUuid.isEmpty) {
          final random = Random();
          final timestamp = DateTime.now().microsecondsSinceEpoch;
          savedUuid = 'web-${timestamp}-${random.nextInt(10000)}';
          await prefs.setString(_webUuidKey, savedUuid);
        }
        uuid = savedUuid;
      } else {
        // Mobile (Android/iOS)
        if (defaultTargetPlatform == TargetPlatform.android) {
          final AndroidDeviceInfo android = await deviceInfo.androidInfo;
          model = android.model;
          os = "Android ${android.version.release}";
          uuid = android.id;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final IosDeviceInfo ios = await deviceInfo.iosInfo;
          model = ios.name;
          os = "iOS ${ios.systemVersion}";
          uuid = ios.identifierForVendor ?? 'Unknown-iOS-ID';
        }
      }
    } catch (e) {
      debugPrint('--- DEVICE_INFO_ERROR: $e');
    }

    return {'model': model, 'os': os, 'uuid': uuid};
  }
}
