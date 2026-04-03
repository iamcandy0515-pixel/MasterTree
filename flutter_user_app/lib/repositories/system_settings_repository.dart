import '../core/api_service.dart';

class SystemSettingsRepository {
  Future<String> getUserNotification() async {
    try {
      return await ApiService.getUserNotification();
    } catch (e) {
      return '';
    }
  }
}
