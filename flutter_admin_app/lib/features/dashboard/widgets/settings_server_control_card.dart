import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsServerControlCard extends StatelessWidget {
  const SettingsServerControlCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시스템 제어',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: '관리자 API 서버 재시작',
            icon: Icons.admin_panel_settings,
            color: Colors.orangeAccent,
            onPressed: () => _showConfirm(context, '관리자 서버를 재시작하시겠습니까?', vm.restartAdminServer),
            isLoading: vm.isLoading,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: '사용자 API 서버 재시작',
            icon: Icons.person,
            color: Colors.blueAccent,
            onPressed: () => _showConfirm(context, '사용자 서버를 재시작하시겠습니까?', vm.restartUserServer),
            isLoading: vm.isLoading,
          ),
          const SizedBox(height: 12),
          const Text(
            '* 서버 재시작 시 약 10~30초간 접속이 끊길 수 있습니다.',
            style: TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.05),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  void _showConfirm(BuildContext context, String title, Future<void> Function() action) {
    showDialog<dynamic>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E24),
        title: const Text('알림', style: TextStyle(color: Colors.white)),
        content: Text(title, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await action();
            },
            child: const Text('확인', style: TextStyle(color: Color(0xFFCCFF00))),
          ),
        ],
      ),
    );
  }
}

