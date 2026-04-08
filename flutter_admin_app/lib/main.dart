import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/auth/screens/login_screen.dart';
import 'package:flutter_admin_app/core/globals.dart';
import 'package:flutter_admin_app/core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable all debugPrints in release mode (Security)
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  await dotenv.load(fileName: ".env");
  AppLogger.d('Admin App Initialized', tag: 'BOOT');

  // [1] 빌드 시 주입된 변수(--dart-define)가 있으면 우선 사용, 없으면 .env 사용
  const String envUrl = String.fromEnvironment('SUPABASE_URL');
  const String envKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  final String supabaseUrl = envUrl.isNotEmpty 
      ? envUrl 
      : dotenv.get('SUPABASE_URL');
  final String supabaseAnonKey = envKey.isNotEmpty 
      ? envKey 
      : dotenv.get('SUPABASE_ANON_KEY');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MasterTree Admin',
      theme: NeoTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}

