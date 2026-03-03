import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/log_repository.dart';

class LogCheckViewModel extends ChangeNotifier {
  final _repo = LogRepository();
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = false;

  LogCheckViewModel() {
    refreshLogs();
  }

  List<Map<String, dynamic>> get logs => _logs;
  bool get isLoading => _isLoading;

  Future<void> clearLogs() async {
    try {
      await _repo.clearLogs();
      _logs = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing logs: $e');
    }
  }

  Future<void> refreshLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _logs = await _repo.getLogs();
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
