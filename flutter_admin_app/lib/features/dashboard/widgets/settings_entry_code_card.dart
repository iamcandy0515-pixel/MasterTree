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
            '입장코드',
            style: TextStyle(color: Colors.white70, fontSize: 14),
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
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: vm.isLoading && vm.entryCode != _controller.text
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCCFF00)),
                      )
                    : const Text(
                        '저장',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '* 사용자 앱에서 로그인 시 사용하는 4~6자리 코드입니다.',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '기존 사용자 입장코드 초기화',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '이미 가입된 사용자의 코드를 위 코드로 맞춥니다.',
                    style: TextStyle(color: Colors.white24, fontSize: 11),
                  ),
                ],
              ),
              TextButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1A2E24),
                            title: const Text('입장코드 초기화', style: TextStyle(color: Colors.white)),
                            content: Text(
                              '현재 설정된 코드(${vm.entryCode})로 모든 사용자의 정보를 업데이트하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('취소', style: TextStyle(color: Colors.white54)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('초기화 실행', style: TextStyle(color: Color(0xFFCCFF00))),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && mounted) {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final count = await vm.resetUserEntryCodes();
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('총 $count명의 사용자 코드가 초기화되었습니다.')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('초기화 실패: $e')),
                              );
                            }
                          }
                        }
                      },
                child: const Text(
                  '초기화',
                  style: TextStyle(
                    color: Color(0xFFCCFF00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
