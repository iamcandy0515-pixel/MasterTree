import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get apiUrl =>
      dotenv.env['API_URL'] ??
      (kIsWeb ? 'http://localhost:4000/api' : 'http://10.0.2.2:4000/api');
}
