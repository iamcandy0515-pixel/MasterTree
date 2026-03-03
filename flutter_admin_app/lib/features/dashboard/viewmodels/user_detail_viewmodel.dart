import 'package:flutter/material.dart';
import '../../trees/repositories/tree_repository.dart';

class UserDetailViewModel extends ChangeNotifier {
  final TreeRepository _repository = TreeRepository();
  final String userId;

  UserDetailViewModel(this.userId);

  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _repository.getUserPerformanceStats(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
