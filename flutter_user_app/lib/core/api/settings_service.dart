import 'base_api_service.dart';
import '../constants.dart';

class SettingsService extends BaseApiService {
  static Future<String> getUserNotification() async {
    try {
      final response = await BaseApiService.get(
        Uri.parse('${AppConstants.apiUrl}/settings/notice'),
      );
      // API returns: { success: true, data: { notice: "message" } }
      if (response != null && response['success'] == true) {
        return (response['data']['notice'] as String?) ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
