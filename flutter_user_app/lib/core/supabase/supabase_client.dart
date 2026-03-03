import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static final SupabaseClient client = SupabaseClient(
    'YOUR_SUPABASE_URL',
    'YOUR_SUPABASE_ANON_KEY',
  );
}
