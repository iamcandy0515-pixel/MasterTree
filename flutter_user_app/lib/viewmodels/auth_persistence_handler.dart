import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin AuthPersistenceHandler on ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(text: '010-');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController entryCodeController = TextEditingController();

  Future<void> loadSavedData({required Function(bool?) onUserStatusLoaded}) async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('test_name') ?? '';
    phoneController.text = prefs.getString('test_phone') ?? '010-';
    emailController.text = prefs.getString('test_email') ?? '';
    entryCodeController.text = prefs.getString('test_entry_code') ?? '';

    if (nameController.text.isNotEmpty && phoneController.text.length >= 12) {
      onUserStatusLoaded(prefs.getBool('is_existing_user') ?? true);
    }
    notifyListeners();
  }

  Future<void> saveData(bool? isExistingUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_name', nameController.text.trim());
    await prefs.setString('test_phone', phoneController.text.trim());
    await prefs.setString('test_email', emailController.text.trim());
    await prefs.setString('test_entry_code', entryCodeController.text.trim());
    await prefs.setBool('is_existing_user', isExistingUser ?? false);
  }

  Future<void> clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    nameController.clear();
    phoneController.text = '010-';
    emailController.clear();
    entryCodeController.clear();
    notifyListeners();
  }

  void disposeControllers() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    entryCodeController.dispose();
  }
}
