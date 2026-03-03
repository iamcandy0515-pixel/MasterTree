import 'package:flutter/material.dart';

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
  final List<AdminNotification> _notifications = [
    AdminNotification(
      id: '1',
      title: '입장 코드 만료 경고',
      message: '체험 학습 A 그룹의 입장 코드가 30분 후 만료됩니다. 연장이 필요하면 확인해 주세요.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.entranceCode,
    ),
    AdminNotification(
      id: '2',
      title: '비정상 로그인 감지',
      message: 'IP 192.168.0.45에서 연속 5회 로그인 실패가 발생했습니다.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.security,
    ),
    AdminNotification(
      id: '3',
      title: '시스템 점검 공지',
      message: '내일 새벽 02:00 ~ 04:00 사이에 서버 정기 점검이 예정되어 있습니다.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.system,
    ),
    AdminNotification(
      id: '4',
      title: '서버 에러 발생',
      message:
          'Critical: Database connection timeout occurred in module TreeDB.',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      type: NotificationType.security,
    ),
  ];

  List<AdminNotification> get notifications => _notifications;

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
