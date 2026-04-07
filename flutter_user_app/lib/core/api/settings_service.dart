import 'base_api_service.dart';
import '../constants.dart';

class SettingsService extends BaseApiService {
  static Future<String> getUserNotification() async {
    try {
      final Map<String, dynamic> response = await BaseApiService.get(
        Uri.parse('${AppConstants.apiUrl}/settings/notice'),
      );
      // API returns: { success: true, data: { notice: "message" } }
      if (response['success'] == true) {
        return ((response['data'] as Map<String, dynamic>)['notice'] as String?) ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
