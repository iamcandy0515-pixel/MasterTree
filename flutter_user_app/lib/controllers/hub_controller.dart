import 'package:flutter/material.dart';
import '../core/supabase_service.dart';

class HubController {
  bool isLoading = true;

  Future<void> initializeAuth({required VoidCallback onUpdate}) async {
    isLoading = true;
    onUpdate();

    try {
      if (!SupabaseService.isLoggedIn) {
        await SupabaseService.signInAnonymously();
      }
    } catch (e) {
      if (e.toString().contains('anonymous_provider_disabled')) {
        debugPrint(
          'CRITICAL: Supabase Anonymous Provider is disabled. Please enable it in the Supabase Dashboard.',
        );
      } else {
        debugPrint('Auth initialization error: $e');
      }
    } finally {
      isLoading = false;
      onUpdate();
    }
  }
}
