import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/widgets/auth_wrapper.dart';
import 'package:flutter_user_app/core/constants.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/providers/quiz_provider.dart';
import 'package:flutter_user_app/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Silence all logs in release mode (Safety)
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  try {
    await dotenv.load(fileName: "assets/env_config");
  } catch (e) {
    debugPrint('Config load skip: $e');
  }

  final String sUrl = AppConstants.supabaseUrl;
  final String aUrl = AppConstants.apiUrl;
  
  // 브라우저 보이지 않는 로그로 주소 출력 (디버깅용)
  print('--- SYSTEM BOOT ---');
  print('API: $aUrl');
  print('SUPA: $sUrl');

  print('BOOT: Initializing Supabase...');
  await Supabase.initialize(
    url: sUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  print('BOOT: Supabase DONE.');

  // ApiService.init()을 await 하지 않고 백그라운드에서 실행 (화면 멈춤 방지)
  print('BOOT: Initializing ApiService (Background)...');
  ApiService.init().then((_) {
    print('BOOT: ApiService DONE.');
  }).catchError((Object e) {
    print('BOOT: ApiService ERROR: $e');
  });

  print('BOOT: Running App...');
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => QuizProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Master Tree User',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        fontFamily: 'Lexend',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
