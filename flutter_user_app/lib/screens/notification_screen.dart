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
    const Color primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '알림 센터',
          style: AppTypography.titleSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryColor),
            onPressed: viewModel.isLoading ? null : () => viewModel.loadNotifications(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '시스템 공지 및 안내',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E261A), // Dark Green Moss
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.campaign_rounded, color: primaryColor, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'OFFICIAL NOTICE',
                              style: TextStyle(
                                color: primaryColor.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          viewModel.notifications.isEmpty
                              ? '현재 등록된 시스템 공지사항이 없습니다.'
                              : viewModel.notifications.first.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              viewModel.notifications.isEmpty ? '-' : _formatRelativeTime(viewModel.notifications.first.timestamp),
                              style: const TextStyle(color: Colors.white30, fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '시스템 정상',
                                style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'MasterTree App 알림 시스템은\n실시간 정책 반영과 학습 정보 전달을 위해 상시 가동 중입니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white24, fontSize: 11, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${timestamp.month}월 ${timestamp.day}일';
  }
}
