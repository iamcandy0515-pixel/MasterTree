import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/screens/login_screen.dart';
import 'package:flutter_user_app/core/constants.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/providers/quiz_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Supabase Init: ${AppConstants.supabaseUrl}');
  debugPrint('Key Prefix: ${AppConstants.supabaseAnonKey.substring(0, 5)}...');

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // 로컬 캐시 초기화
  await ApiService.init();

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
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (BuildContext context) =>
              const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
