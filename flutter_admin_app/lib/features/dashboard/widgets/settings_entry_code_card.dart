import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsEntryCodeCard extends StatefulWidget {
  final String initialCode;
  const SettingsEntryCodeCard({super.key, required this.initialCode});

  @override
  State<SettingsEntryCodeCard> createState() => _SettingsEntryCodeCardState();
}

class _SettingsEntryCodeCardState extends State<SettingsEntryCodeCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
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
            '입장 코드',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
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
              TextButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final newCode = _controller.text.trim();
                        if (newCode.isEmpty) return;
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await vm.updateEntryCode(newCode);
                          messenger.showSnackBar(
                            const SnackBar(content: Text('접속 코드가 변경되었습니다.')),
                          );
                        } catch (e) {
                          // Error handled in VM
                        }
                      },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFCCFF00),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: vm.isLoading && vm.entryCode != _controller.text
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCCFF00)),
                      )
                    : const Text('변경 저장'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '* 사용자 앱에서 로그인 시 사용하는 4~6자리 코드입니다.',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

