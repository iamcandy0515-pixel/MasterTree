import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin BulkPersistenceMixin on ChangeNotifier {
  bool _isDirty = false;

  void markDirty() {
    _isDirty = true;
  }

  void markClean() {
    _isDirty = false;
  }

  /// Backup full quiz data to SharedPreferences
  /// Only executes if data is marked dirty to optimize mobile performance
  Future<void> saveBackupLocal(Map<int, Map<String, dynamic>> quizzes) async {
    if (!_isDirty && quizzes.isNotEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = quizzes.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString('bulk_extraction_backup', jsonEncode(data));
      markClean();
    } catch (e) {
      debugPrint('Error saving backup: $e');
    }
  }

  /// Load backup data from SharedPreferences
  Future<Map<int, Map<String, dynamic>>> loadBackupLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('bulk_extraction_backup');
      if (json != null) {
        final Map<int, Map<String, dynamic>> extractedQuizzes = {};
        final data = jsonDecode(json) as Map<String, dynamic>;
        data.forEach((k, dynamic v) {
          extractedQuizzes[int.parse(k)] = Map<String, dynamic>.from(v as Map);
        });
        return extractedQuizzes;
      }
    } catch (e) {
      debugPrint('Error loading backup: $e');
    }
    return <int, Map<String, dynamic>>{};
  }

  /// Remove backup data
  Future<void> clearBackupLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bulk_extraction_backup');
      markClean();
    } catch (e) {
      debugPrint('Error clearing backup: $e');
    }
  }
}
