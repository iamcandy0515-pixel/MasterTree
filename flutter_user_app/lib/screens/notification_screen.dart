import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/design_system.dart';
import '../viewmodels/notification_viewmodel.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(),
      child: const _NotificationContent(),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  const _NotificationContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    const Color primaryColor = AppColors.primary; // 디자인 시스템의 메인 컬러 사용

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text(
          '알림 센터',
          style: AppTypography.titleSmall,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationViewModel>().markAllAsRead();
            },
            child: const Text('모두 읽음', style: TextStyle(color: primaryColor)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : viewModel.notifications.isEmpty
              ? const Center(
                  child: Text(
                    '새로운 알림이 없습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: viewModel.notifications.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  itemBuilder: (context, index) {
                    final notification = viewModel.notifications[index];
                    return _buildNotificationItem(
                      context,
                      notification,
                      primaryColor,
                    );
                  },
                ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    AdminNotification notification,
    Color primaryColor,
  ) {
    IconData icon = Icons.info_outline;
    Color iconColor = primaryColor;

    switch (notification.type) {
      case NotificationType.entranceCode:
        icon = Icons.key_off;
        iconColor = Colors.orangeAccent;
        break;
      case NotificationType.security:
        icon = Icons.gpp_maybe;
        iconColor = Colors.redAccent;
        break;
      case NotificationType.system:
        icon = Icons.campaign_rounded;
        iconColor = primaryColor;
        break;
    }

    return InkWell(
      onTap: () {
        context.read<NotificationViewModel>().markAsRead(notification.id);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        color: notification.isRead
            ? Colors.transparent
            : Colors.white.withOpacity(0.03),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          color: notification.isRead
                              ? Colors.grey[400]
                              : Colors.white,
                          fontSize: 15,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${timestamp.month}월 ${timestamp.day}일';
    }
  }
}
