import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          SettingsViewModel()..loadSettings(), // Changed to loadSettings
      child: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatefulWidget {
  const _SettingsContent();

  @override
  State<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent> {
  final TextEditingController _entryCodeController = TextEditingController();
  final TextEditingController _userAppUrlController =
      TextEditingController(); // New
  final TextEditingController _googleDriveUrlController =
      TextEditingController(); // New

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _entryCodeController.dispose();
    _userAppUrlController.dispose(); // New
    _googleDriveUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    // Sync controller with vm value initially
    if (_entryCodeController.text.isEmpty &&
        !vm.isInitialLoading &&
        vm.entryCode.isNotEmpty) {
      _entryCodeController.text = vm.entryCode;
    }
    // Sync User App URL
    if (_userAppUrlController.text.isEmpty &&
        !vm.isInitialLoading &&
        vm.userAppUrl.isNotEmpty) {
      _userAppUrlController.text = vm.userAppUrl;
    }
    // Sync Google Drive URL
    if (_googleDriveUrlController.text.isEmpty &&
        !vm.isInitialLoading &&
        vm.googleDriveUrl.isNotEmpty) {
      _googleDriveUrlController.text = vm.googleDriveUrl;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF102219),
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF102219),
        elevation: 0,
      ),
      body: vm.isInitialLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2BEE8C)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vm.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vm.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),

                  // Section 1: Entry Code
                  _buildSectionHeader('앱 접속 코드 관리', Icons.lock_outline),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2E24),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '현재 설정된 접속 코드',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _entryCodeController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black26,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      final newCode = _entryCodeController.text
                                          .trim();
                                      if (newCode.isEmpty) return;
                                      try {
                                        await context
                                            .read<SettingsViewModel>()
                                            .updateEntryCode(newCode);
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('접속 코드가 변경되었습니다.'),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        //
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCCFF00),
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('변경 저장'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '* 사용자 앱에서 로그인 시 사용되는 4~6자리 코드입니다.',
                          style: TextStyle(color: Colors.white30, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Section 2: User App QR Code
                  _buildSectionHeader('사용자 앱 QR코드 생성', Icons.qr_code_2),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2E24),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // QR Code Image
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: QrImageView(
                                  data: vm.userAppUrl,
                                  version: QrVersions.auto,
                                  size: 130.0,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // URL Input
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '사용자 앱 웹 주소 (URL)',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _userAppUrlController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.black26,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      hintText: 'http://...',
                                      hintStyle: TextStyle(
                                        color: Colors.white30,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: vm.isLoading
                                          ? null
                                          : () async {
                                              final newUrl =
                                                  _userAppUrlController.text
                                                      .trim();
                                              if (newUrl.isEmpty) return;
                                              try {
                                                await context
                                                    .read<SettingsViewModel>()
                                                    .updateUserAppUrl(newUrl);
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'URL이 변경되고 QR코드가 갱신되었습니다.',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                //
                                              }
                                            },
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('URL 저장 및 QR 갱신'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white10,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '* 이 QR코드를 사용자에게 보여주어 앱에 접속하게 할 수 있습니다.\n* 설정된 URL에 따라 QR코드가 실시간으로 생성됩니다.',
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Section 2.5: Google Drive Setup
                  _buildSectionHeader('기출문제 설정', Icons.cloud_download_outlined),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2E24),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '구글 드라이브 폴더 URL',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _googleDriveUrlController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black26,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText:
                                      'https://drive.google.com/drive/folders/...',
                                  hintStyle: const TextStyle(
                                    color: Colors.white30,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      final newUrl = _googleDriveUrlController
                                          .text
                                          .trim();
                                      try {
                                        await context
                                            .read<SettingsViewModel>()
                                            .updateGoogleDriveFolderUrl(newUrl);
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '구글 드라이브 URL이 저장되었습니다.',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        // Handle error
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF2BEE8C,
                                ), // primaryColor
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                '변경 저장',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '* 파일 추출에 사용할 공용 구글 드라이브 폴더의 공유 링크를 입력하세요.\n* (주의) 누구나 액세스할 수 있는 링크여야 목록 조회가 가능합니다.',
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Section 3: System Management
                  _buildSectionHeader('시스템 관리', Icons.settings_system_daydream),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2E24),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        _buildSystemActionTile(
                          context,
                          title: '관리자 서버 재시작',
                          subtitle: 'Admin API 서버를 강제로 재시작합니다.',
                          icon: Icons.admin_panel_settings,
                          color: Colors.orangeAccent,
                          onTap: () => _confirmRestart(
                            context,
                            '관리자 서버',
                            vm.restartAdminServer,
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 32),
                        _buildSystemActionTile(
                          context,
                          title: '사용자 서버 재시작',
                          subtitle: 'User App 서버를 강제로 재시작합니다.',
                          icon: Icons.person_outline,
                          color: Colors.blueAccent,
                          onTap: () => _confirmRestart(
                            context,
                            '사용자 서버',
                            vm.restartUserServer,
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFCCFF00), size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('재시작'),
        ),
      ],
    );
  }

  Future<void> _confirmRestart(
    BuildContext context,
    String targetName,
    Future<void> Function() onConfirm,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E24),
        title: Text(
          '$targetName 재시작',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '정말로 $targetName를 재시작하시겠습니까?\n잠시 동안 서비스가 중단될 수 있습니다.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('재시작 확인'),
          ),
        ],
      ),
    );

    if (result == true) {
      await onConfirm();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$targetName 재시작 요청을 보냈습니다.')));
      }
    }
  }
}
