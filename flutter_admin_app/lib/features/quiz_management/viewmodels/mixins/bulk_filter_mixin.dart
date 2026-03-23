import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin BulkFilterMixin on ChangeNotifier {
  String? subject;
  int? year;
  int? round;
  String? fileId;
  int startNumber = 0;
  int endNumber = 0;

  bool get isFilterComplete =>
      subject != null &&
      year != null &&
      round != null &&
      fileId != null &&
      startNumber > 0 &&
      endNumber > 0 &&
      startNumber <= endNumber;

  void updateFilters({
    String? subject,
    int? year,
    int? round,
    String? fileId,
    int? start,
    int? end,
  }) {
    if (subject != null) this.subject = subject;
    if (year != null) this.year = year;
    if (round != null) this.round = round;
    if (fileId != null) this.fileId = fileId;
    if (start != null) startNumber = start;
    if (end != null) endNumber = end;

    saveFilters();
    notifyListeners();
  }

  Future<void> loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    subject = prefs.getString('ext_filter_subject');
    year = prefs.getInt('ext_filter_year');
    round = prefs.getInt('ext_filter_round');
    fileId = prefs.getString('ext_filter_file_id');
    startNumber = prefs.getInt('ext_filter_start') ?? 0;
    endNumber = prefs.getInt('ext_filter_end') ?? 0;
    notifyListeners();
  }

  Future<void> saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    if (subject != null) await prefs.setString('ext_filter_subject', subject!);
    if (year != null) await prefs.setInt('ext_filter_year', year!);
    if (round != null) await prefs.setInt('ext_filter_round', round!);
    if (fileId != null) await prefs.setString('ext_filter_file_id', fileId!);
    await prefs.setInt('ext_filter_start', startNumber);
    await prefs.setInt('ext_filter_end', endNumber);
  }
}
