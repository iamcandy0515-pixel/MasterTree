import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsDriveCard extends StatefulWidget {
  const SettingsDriveCard({super.key});

  @override
  State<SettingsDriveCard> createState() => _SettingsDriveCardState();
}

class _SettingsDriveCardState extends State<SettingsDriveCard> {
  final TextEditingController _examController = TextEditingController();
  final TextEditingController _googleController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();

  @override
  void dispose() {
    _examController.dispose();
    _googleController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _openFolder(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    // Initial sync
    if (_examController.text.isEmpty && vm.examDriveUrl.isNotEmpty) {
      _examController.text = vm.examDriveUrl;
    }
    if (_googleController.text.isEmpty && vm.googleDriveUrl.isNotEmpty) {
      _googleController.text = vm.googleDriveUrl;
    }
    if (_thumbnailController.text.isEmpty && vm.thumbnailDriveUrl.isNotEmpty) {
      _thumbnailController.text = vm.thumbnailDriveUrl;
    }

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
          _buildDriveInput(
            label: '구글 기출문제 폴더 URL',
            controller: _examController,
            vmKey: 'examDrive',
            onSave: (val) => vm.updateExamDriveUrl(val),
          ),
          const SizedBox(height: 24),
          _buildDriveInput(
            label: '구글 수목 이미지 폴더 URL',
            controller: _googleController,
            vmKey: 'googleDrive',
            onSave: (val) => vm.updateGoogleDriveFolderUrl(val),
          ),
          const SizedBox(height: 24),
          _buildDriveInput(
            label: '구글 썸네일 이미지 폴더 URL',
            controller: _thumbnailController,
            vmKey: 'thumbnailDrive',
            onSave: (val) => vm.updateThumbnailDriveUrl(val),
          ),
          const SizedBox(height: 16),
          const Text(
            '* 추출 및 썸네일 생성 시 참조할 구글 드라이브 폴더의 공유 링크를 입력하세요.\n* (주의) 누구나 액세스할 수 있는 링크여야 목록 조회가 가능합니다.',
            style: TextStyle(color: Colors.white30, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveInput({
    required String label,
    required TextEditingController controller,
    required String vmKey,
    required Future<void> Function(String) onSave,
  }) {
    final vm = context.read<SettingsViewModel>();
    final isOk = vm.getUrlStatus(vmKey);
    final isChecking = vm.isCheckLoading(vmKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () => _openFolder(controller.text),
                child: Row(
                  children: const [
                    Text('폴더 열기', style: TextStyle(color: Color(0xFFCCFF00), fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.open_in_new, size: 12, color: Color(0xFFCCFF00)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'https://drive.google.com/...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await onSave(controller.text.trim());
                        messenger.showSnackBar(
                          const SnackBar(content: Text('저장되었습니다.')),
                        );
                      } catch (e) {
                        // Error is handled in the ViewModel
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCFF00),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('저장'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Status Row
        Row(
          children: [
            if (isChecking)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2BEE8C)),
              )
            else if (isOk != null)
              Icon(
                isOk ? Icons.check_circle : Icons.error,
                size: 14,
                color: isOk ? Colors.greenAccent : Colors.redAccent,
              ),
            const SizedBox(width: 4),
            Text(
              isChecking
                  ? '연결 확인 중...'
                  : (isOk == null ? '연결 미확인' : (isOk ? '정상적인 링크입니다.' : '연결할 수 없는 링크입니다.')),
              style: TextStyle(
                fontSize: 11,
                color: isChecking
                    ? Colors.white54
                    : (isOk == true ? Colors.greenAccent : (isOk == false ? Colors.redAccent : Colors.white30)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

