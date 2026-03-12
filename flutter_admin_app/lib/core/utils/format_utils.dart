class FormatUtils {
  /// 01012345678 -> 010-1234-5678
  static String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '-';
    // Remove 'u' prefix if it exists (internal Auth compatibility)
    String clean = phone;
    if (clean.startsWith('u')) {
      clean = clean.substring(1);
    }
    // Remove any non-digits
    final digits = clean.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    return phone;
  }

  /// Clean virtual email for display: u01012345678@mastertree.app -> 010-1234-5678
  static String formatVirtualEmail(String? email) {
    if (email == null || !email.endsWith('@mastertree.app')) return email ?? '-';
    final localPart = email.split('@')[0];
    return formatPhone(localPart);
  }
}
