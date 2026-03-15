import 'package:flutter/services.dart';

/// Custom formatter for Korean phone numbers (010-XXXX-XXXX) with fixed '010-' prefix
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    // 1. Force prefix '010-'
    if (!text.startsWith('010-')) {
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
      if (i == 3 && suffix.length > 4) {
        formatted += '-';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
