import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get apiUrl {
    // [1] 諛고룷(Release) 紐⑤뱶???뚮뒗 ?먮룞?쇰줈 ?ㅼ젣 ?댁쁺 API 二쇱냼 ?ъ슜
    if (kReleaseMode) {
      return 'https://mastertree-api.vercel.app/api';
    }
    // [2] 媛쒕컻(Debug) 紐⑤뱶???뚮뒗 .env ???ㅼ젙??二쇱냼 ?곗꽑 ?ъ슜 (濡쒖뺄 ?뚯뒪?몄슜)
    return dotenv.env['APP_BASE_URL'] ??
        (kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:4000/api');
  }
}
