import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/screens/dashboard_screen.dart';
import 'package:flutter_user_app/viewmodels/auth_viewmodel.dart';
import 'widgets/login_parts/login_header.dart';
import 'widgets/login_parts/login_input_fields.dart';
import 'widgets/login_parts/login_action_buttons.dart';
import 'widgets/login_parts/login_status_overlay.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel()..initialize(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AuthViewModel>();
      vm.nameController.addListener(vm.onInputChanged);
      vm.phoneController.addListener(vm.onInputChanged);
    });
  }

  Future<void> _handleLogin(AuthViewModel vm) async {
    await vm.handleLogin(
      formKey: _formKey,
      onSuccess: () => Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(builder: (BuildContext context) => const DashboardScreen()),
      ),
      onError: (String message) => _showErrorDialog(message, vm),
    );
  }

  void _showErrorDialog(String message, AuthViewModel vm) {
    String title = '알림';
    String content = message;
    bool showRefresh = false;

    if (message == 'status_pending') {
      title = '승인 대기 중';
      content = '관리자의 승인을 기다리고 있습니다.\n승인 완료 후 서비스 이용이 가능합니다.';
      showRefresh = true;
    } else if (message == 'status_denied' || message == 'status_rejected') {
      title = '접근 제한';
      content = '관리자에 의해 접근이 거부되었거나\n사용 기간이 만료되었습니다.';
    } else if (message == 'status_expired') {
      title = '기간 만료';
      content = '사용 기간이 만료되었습니다.\n관리자에게 문의해 주세요.';
    } else if (message.startsWith('ALREADY_LOGGED_IN:')) {
      final deviceModel = message.split(':')[1];
      _showConflictDialog(deviceModel, vm);
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: !showRefresh,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              showRefresh ? Icons.hourglass_empty : Icons.info_outline,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: AppColors.textLight),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          if (showRefresh)
            TextButton.icon(
              onPressed: () {
                Navigator.pop<void>(context);
                _handleLogin(vm);
              },
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              label: const Text('상태 새로고침', style: TextStyle(color: AppColors.primary)),
            )
          else
            TextButton(
              onPressed: () => Navigator.pop<void>(context),
              child: const Text('확인', style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  void _showConflictDialog(String deviceModel, AuthViewModel vm) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('중복 로그인 감지', style: TextStyle(color: AppColors.textLight)),
          ],
        ),
        content: Text(
          '이미 [$deviceModel] 에서 로그인되어 있습니다.\n\n해당 기기를 로그아웃하고 이 기기에서 로그인하시겠습니까?',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop<void>(context),
            child: const Text('취소', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop<void>(context);
              vm.handleLogin(
                formKey: _formKey,
                onSuccess: () {
                  if (mounted) {
                    Navigator.pushReplacement<void, void>(
                      context,
                      MaterialPageRoute<void>(builder: (BuildContext context) => const DashboardScreen()),
                    );
                  }
                },
                onError: (String msg) => _showErrorDialog(msg, vm),
                forceLogout: true,
              );
            },
            child: const Text('기존 기기 로그아웃', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginHeader(
                    onClearData: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await vm.clearSavedData();
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('저장된 테스트 데이터가 삭제되었습니다.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: const [
                        LoginInputFields(),
                      ],
                    ),
                  ),
                  LoginActionButtons(onLogin: () => _handleLogin(vm)),
                ],
              ),
            ),
          ),
          const LoginStatusOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      right: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.05),
        ),
      ),
    );
  }
}

