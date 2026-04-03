import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsNotificationCard extends StatefulWidget {
  final String initialNotification;
  const SettingsNotificationCard({super.key, required this.initialNotification});

  @override
  State<SettingsNotificationCard> createState() => _SettingsNotificationCardState();
}

class _SettingsNotificationCardState extends State<SettingsNotificationCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotification);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '사용자 알림 정보 관리',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final newMessage = _controller.text.trim();
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await vm.updateUserNotification(newMessage);
                          messenger.showSnackBar(
                            const SnackBar(content: Text('알림 정보가 저장되었습니다.')),
                          );
                        } catch (e) {
                          // Error handled in VM
                        }
                      },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFCCFF00),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                child: vm.isLoading && vm.userNotification != _controller.text
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCCFF00)),
                      )
                    : const Text('정보 저장'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: '사용자들에게 보여줄 알림 내용을 입력하세요...',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '* 입력된 내용은 사용자 앱의 초기 화면 또는 알림 영역에 노출됩니다.',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
