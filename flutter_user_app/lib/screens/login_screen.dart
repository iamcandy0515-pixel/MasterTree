import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/screens/dashboard_screen.dart';
import 'package:flutter_user_app/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _authController.loadSavedData().then((_) {
      if (mounted) setState(() {});
    });

    // Add listeners for real-time check
    _authController.nameController.addListener(_onInputChanged);
    _authController.phoneController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    _authController.onInputChanged(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _authController.nameController.removeListener(_onInputChanged);
    _authController.phoneController.removeListener(_onInputChanged);
    _authController.dispose();
    super.dispose();
  }

  // Clear saved data
  Future<void> _clearSavedData() async {
    await _authController.clearSavedData();
    if (mounted) setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('저장된 테스트 데이터가 삭제되었습니다.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // Validations
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return '이름을 입력해주세요.';
    if (value.contains(' ')) return '이름에 공백을 포함할 수 없습니다.';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return '휴대전화 번호를 입력해주세요.';
    final phoneRegex = RegExp(r'^010-\d{3,4}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return "올바른 형식(010-0000-0000)으로 입력해주세요.";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (!_authController.showEmailField) return null;
    if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '유효한 이메일 형식이 아닙니다.';
    }
    return null;
  }

  String? _validateEntryCode(String? value) {
    if (value == null || value.isEmpty) return '입장코드를 입력해주세요.';
    return null;
  }

  Future<void> _handleLogin() async {
    await _authController.handleLogin(
      formKey: _formKey,
      onSuccess: _navigateToDashboard,
      onError: (message) => _showErrorDialog(message),
      onUpdate: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('알림', style: TextStyle(color: AppColors.textLight)),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
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
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.forest, color: AppColors.primary, size: 80),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: Text(
                          'Master Tree User',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _clearSavedData,
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.textMuted,
                        tooltip: '저장된 테스트 데이터 삭제',
                      ),
                    ],
                  ),
                  if (_authController.isCheckingServer)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        '사용자 정보 확인 중...',
                        style: TextStyle(color: AppColors.primary, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildLoginForm(),
                ],
              ),
            ),
          ),
          if (_authController.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleLogin,
                child: const Text(
                  '입장하기',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _authController.nameController,
              label: '이름',
              icon: Icons.person_outline,
              validator: _validateName,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _authController.phoneController,
              label: '휴대전화',
              icon: Icons.phone_android_outlined,
              hint: '010-0000-0000',
              validator: _validatePhone,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(sizeFactor: animation, child: child),
                );
              },
              child: _authController.showEmailField
                  ? Padding(
                      key: const ValueKey('email_field'),
                      padding: const EdgeInsets.only(top: 12.0),
                      child: _buildTextField(
                        controller: _authController.emailController,
                        label: '이메일 (신규 등록용)',
                        icon: Icons.email_outlined,
                        validator: _validateEmail,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('email_empty')),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _authController.entryCodeController,
              label: '입장코드',
              icon: Icons.vpn_key_outlined,
              isObscure: true,
              validator: _validateEntryCode,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isObscure = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(color: AppColors.textLight),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.3)),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: false,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}
