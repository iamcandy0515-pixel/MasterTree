import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel()..loadSettings(),
      child: const _NotificationContent(),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  const _NotificationContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    const Color primaryColor = Color(0xFFC6FF00); // Acid Lime

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          '알림 센터',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryColor),
            onPressed: vm.isLoading ? null : () => vm.loadSettings(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: vm.isInitialLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '현재 사용자 앱 공지/안내',
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
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active, color: primaryColor, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'LIVE NOTICE',
                              style: TextStyle(
                                color: primaryColor.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          vm.userNotice.isEmpty ? '등록된 공지사항이 없습니다.' : vm.userNotice,
                          style: TextStyle(
                            color: vm.userNotice.isEmpty ? Colors.white24 : Colors.white,
                            fontSize: 17,
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
                            const Text(
                              '전달 상태',
                              style: TextStyle(color: Colors.white30, fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '정상 송출 중',
                                style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '* 위 내용은 설정의 [사용자 앱 공지사항 설정]에서 변경할 수 있습니다.',
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }
}
