import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  static String get supabaseUrl => const String.fromEnvironment('SUPABASE_URL').isNotEmpty 
      ? const String.fromEnvironment('SUPABASE_URL') 
      : (dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co');

  static String get supabaseAnonKey => const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
      ? const String.fromEnvironment('SUPABASE_ANON_KEY')
      : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  static String get apiUrl {
    const String envApiUrl = String.fromEnvironment('APP_BASE_URL');
    if (envApiUrl.isNotEmpty) return envApiUrl;

    if (kReleaseMode) {
      return 'https://mastertree-api.vercel.app/api';
    }
    return dotenv.env['APP_BASE_URL'] ??
        (kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:4000/api');
  }
}
