import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsNoticeCard extends StatefulWidget {
  final String initialNotice;
  const SettingsNoticeCard({super.key, required this.initialNotice});

  @override
  State<SettingsNoticeCard> createState() => _SettingsNoticeCardState();
}

class _SettingsNoticeCardState extends State<SettingsNoticeCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotice);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            '사용자 앱 상단 공지/안내 문구',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: '사용자 앱 화면 상단에 표시될 안내 문구를 입력하세요.',
              hintStyle: const TextStyle(color: Colors.white24),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      final notice = _controller.text.trim();
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await vm.updateUserNotice(notice);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('공지사항이 저장되었습니다.')),
                        );
                      } catch (e) {
                        // Error handled in VM
                      }
                    },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFCCFF00),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCCFF00)),
                    )
                  : const Text(
                      '공지 저장',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '* 저장된 문구는 사용자 앱의 메인 화면 또는 알림 영역에 즉시 반영됩니다.',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
