import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (!mounted) return;
    setState(() {});
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
    // Standard Korean phone number format for UI: 010-XXXX-XXXX
    final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return "010으로 시작하는 11자리 숫자를 입력해주세요.";
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
    String title = '알림';
    String content = message;
    bool showRefresh = false;

    if (message == 'status_pending') {
      title = '승인 대기 중';
      content = '관리자의 승인을 기다리고 있습니다.\n승인 완료 후 서비스 이용이 가능합니다.';
      showRefresh = true;
    } else if (message == 'status_denied' || message == 'status_rejected') {
      title = '접근 제한';
      content = '관리에 의해 접근이 거부되었거나\n사용 기간이 만료되었습니다.';
    } else if (message == 'status_expired') {
      title = '기간 만료';
      content = '사용 기간이 만료되었습니다.\n관리자에게 문의해 주세요.';
    }

    showDialog(
      context: context,
      barrierDismissible: !showRefresh,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
                Navigator.pop(context);
                _handleLogin(); // Retry login logic to check status
              },
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              label: const Text('상태 새로고침', style: TextStyle(color: AppColors.primary)),
            )
          else
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
                color: AppColors.primary.withValues(alpha: 0.05),
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
              keyboardType: TextInputType.phone,
              inputFormatters: [
                _PhoneNumberFormatter(),
              ],
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
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: AppColors.textLight),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.3)),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: false,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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

/// Custom formatter for Korean phone numbers (010-XXXX-XXXX) with fixed '010-' prefix
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    // 1. Force prefix '010-'
    if (!text.startsWith('010-')) {
      // If user tries to delete or change prefix, restore it unless it was totally empty 
      // which shouldn't happen with our controller setup, but safely return oldValue or base
      if (text.length < 4) {
        return const TextEditingValue(
          text: '010-',
          selection: TextSelection.collapsed(offset: 4),
        );
      }
      return oldValue;
    }

    // 2. Extract only digits after '010-'
    String suffix = text.substring(4).replaceAll(RegExp(r'\D'), '');
    
    // 3. Limit to 8 more digits (total 11 digits)
    if (suffix.length > 8) {
      suffix = suffix.substring(0, 8);
    }

    // 4. Format the suffix as XXXX-XXXX (if needed)
    String formatted = '010-';
    for (int i = 0; i < suffix.length; i++) {
      formatted += suffix[i];
      // Add hyphen after 4 digits of suffix (which is index 7 in total string)
      if (i == 3 && suffix.length > 4) {
        formatted += '-';
      }
    }

    // 5. Handle backspace on hyphen specifically to avoid getting stuck
    // (If the current formatted matches oldValue and it has a hyphen at the end 
    // that the user might be trying to delete)
    if (oldValue.text.length > newValue.text.length && oldValue.text.endsWith('-')) {
        // User attempted backspace on a trailing hyphen - we've already reformatted 
        // in 'formatted', but let's make sure we don't restore the hyphen immediately 
        // if they just deleted a digit that triggered the hyphen. 
        // Actually the logic above (suffix-based) handles this naturally.
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
