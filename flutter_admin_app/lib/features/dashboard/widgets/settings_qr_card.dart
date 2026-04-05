import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsQrCard extends StatefulWidget {
  final String initialUrl;
  const SettingsQrCard({super.key, required this.initialUrl});

  @override
  State<SettingsQrCard> createState() => _SettingsQrCardState();
}

class _SettingsQrCardState extends State<SettingsQrCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final isOk = vm.getUrlStatus('userApp');
    final isChecking = vm.isCheckLoading('userApp');

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QR Code Image
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: QrImageView(
                    data: vm.userAppUrl,
                    version: QrVersions.auto,
                    size: 120.0,
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
                      '사용자 앱 주소 (URL)',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'http://...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status Text
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
                              : (isOk == null ? '연결 미확인' : (isOk ? '연결 정상' : '연결 오류')),
                          style: TextStyle(
                            fontSize: 12,
                            color: isChecking
                                ? Colors.white54
                                : (isOk == true ? Colors.greenAccent : (isOk == false ? Colors.redAccent : Colors.white30)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                                final newUrl = _controller.text.trim();
                                if (newUrl.isEmpty) return;
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  await vm.updateUserAppUrl(newUrl);
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('URL이 저장되었습니다.')),
                                  );
                                } catch (e) {
                                  // Error handled in VM
                                }
                              },
                        icon: vm.isLoading
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCCFF00)))
                            : const Icon(Icons.save, size: 16, color: Color(0xFFCCFF00)),
                        label: const Text(
                          'URL 저장',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFCCFF00),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
            '* 설정된 URL에 따라 QR코드가 실시간으로 생성됩니다.\n* 카메라로 이 QR을 스캔하면 앱에 즉시 접속할 수 있습니다.',
            style: TextStyle(color: Colors.white30, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}
