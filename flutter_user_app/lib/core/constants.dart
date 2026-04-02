import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get apiUrl {
    // [1] 배포(Release) 모드일 때는 자동으로 실제 운영 API 주소 사용
    if (kReleaseMode) {
      return 'https://mastertree-api-final.vercel.app/api';
    }
    // [2] 개발(Debug) 모드일 때는 .env 에 설정된 주소 우선 사용 (로컬 테스트용)
    return dotenv.env['API_URL'] ??
        (kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:4000/api');
  }
}
