import 'package:flutter/material.dart';
import '../repositories/system_settings_repository.dart';

enum NotificationType { entranceCode, security, system }

class AdminNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

class NotificationViewModel extends ChangeNotifier {
  final SystemSettingsRepository _repository = SystemSettingsRepository();

  List<AdminNotification> _notifications = [];
  List<AdminNotification> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NotificationViewModel() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String message = await _repository.getUserNotification();
      
      _notifications = [];
      if (message.isNotEmpty) {
        _notifications.add(
          AdminNotification(
            id: 'current_user_notif',
            title: '시스템 공지사항',
            message: message,
            timestamp: DateTime.now(),
            type: NotificationType.system,
          ),
        );
      }
    } catch (e) {
      debugPrint('사용자 알림 로드 중 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }
}
