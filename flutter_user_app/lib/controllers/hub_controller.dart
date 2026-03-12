import 'package:flutter/material.dart';
import '../core/supabase_service.dart';

class HubController {
  bool isLoading = true;

  Future<void> initializeAuth({required VoidCallback onUpdate}) async {
    isLoading = true;
    onUpdate();

    try {
      // Background auth init - with permanent accounts, 
      // we only check if existing session is valid.
      // If not, the screen will handle redirection to LoginScreen.
      final isLoggedIn = SupabaseService.isLoggedIn;
      debugPrint('Auth check: isLoggedIn = $isLoggedIn');
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      isLoading = false;
      onUpdate();
    }
  }
}
