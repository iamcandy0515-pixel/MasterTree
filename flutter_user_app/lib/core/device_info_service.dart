import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
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
        uuid = 'web-${web.userAgent ?? 'Unknown-Web-ID'}';
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
