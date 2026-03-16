import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/settings_entry_code_card.dart';
import '../widgets/settings_qr_card.dart';
import '../widgets/settings_drive_card.dart';
import '../widgets/settings_server_control_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel()..loadSettings(),
      child: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF102219),
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF102219),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFCCFF00)),
            onPressed: vm.isLoading ? null : () => vm.loadSettings(),
          ),
        ],
      ),
      body: vm.isInitialLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2BEE8C)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
                  SettingsEntryCodeCard(initialCode: vm.entryCode),

                  const SizedBox(height: 32),

                  // Section 2: User App QR Code
                  _buildSectionHeader('사용자 앱 QR코드 생성', Icons.qr_code_2),
                  const SizedBox(height: 16),
                  SettingsQrCard(initialUrl: vm.userAppUrl),

                  const SizedBox(height: 32),

                  // Section 3: Tree Image Setup (Google Drive)
                  _buildSectionHeader('수목 이미지 설정', Icons.image_outlined),
                  const SizedBox(height: 16),
                  const SettingsDriveCard(),

                  const SizedBox(height: 32),

                  // Section 4: Server Control
                  _buildSectionHeader('시스템 설정 및 제어', Icons.settings_remote),
                  const SizedBox(height: 16),
                  const SettingsServerControlCard(),

                  const SizedBox(height: 48),

                  /*
                  // LEGACY: Old Settings UI Section (Commented for lightweight refactoring)
                  // Previously about 400 lines of hardcoded cards and logic
                  // ...
                  */
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFCCFF00), size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

