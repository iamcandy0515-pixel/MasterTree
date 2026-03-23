import 'package:shared_preferences/shared_preferences.dart';

mixin ExamPersistenceMixin {
  Future<void> saveFilters({
    String? subject,
    String? year,
    String? session,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (subject != null) await prefs.setString('user_exam_subject', subject);
    if (year != null) await prefs.setString('user_exam_year', year);
    if (session != null) await prefs.setString('user_exam_session', session);
  }

  Future<Map<String, String?>> loadSavedFiltersData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'subject': prefs.getString('user_exam_subject'),
      'year': prefs.getString('user_exam_year'),
      'session': prefs.getString('user_exam_session'),
    };
  }
}
