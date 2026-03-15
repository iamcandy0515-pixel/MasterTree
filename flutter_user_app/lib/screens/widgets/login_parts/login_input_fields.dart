import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/design_system.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../../utils/auth_data_formatter.dart';

class LoginInputFields extends StatelessWidget {
  const LoginInputFields({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AuthViewModel>();

    return Column(
      children: [
        _buildTextField(
          controller: vm.nameController,
          label: '이름',
          icon: Icons.person_outline,
          validator: vm.validateName,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: vm.phoneController,
          label: '휴대전화',
          icon: Icons.phone_android_outlined,
          hint: '010-0000-0000',
          keyboardType: TextInputType.phone,
          inputFormatters: [PhoneNumberFormatter()],
          validator: vm.validatePhone,
        ),
        Selector<AuthViewModel, bool>(
          selector: (_, vm) => vm.showEmailField,
          builder: (context, showEmail, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(sizeFactor: animation, child: child),
                );
              },
              child: showEmail
                  ? Padding(
                      key: const ValueKey('email_field'),
                      padding: const EdgeInsets.only(top: 12.0),
                      child: _buildTextField(
                        controller: vm.emailController,
                        label: '이메일 (신규 등록용)',
                        icon: Icons.email_outlined,
                        validator: vm.validateEmail,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('email_empty')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: vm.entryCodeController,
          label: '입장코드',
          icon: Icons.vpn_key_outlined,
          isObscure: true,
          validator: vm.validateEntryCode,
        ),
      ],
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
            hintStyle: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.3),
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: false,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
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
