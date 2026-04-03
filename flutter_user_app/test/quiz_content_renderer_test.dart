import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter_user_app/features/quiz/widgets/quiz_content_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // PathProvider Mocking (Absolute Path 제공)
  const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler((MethodCall methodCall) async {
    return Directory.current.path; // 절대 경로를 반환하여 유효성 확보
  });

  group('QuizContentRenderer Golden Tests', () {
    testWidgets('renders plain text correctly', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: QuizContentRenderer(content: '이것은 일반적인 텍스트 퀴즈 지문입니다.'),
            ),
          ),
        );

        await expectLater(
          find.byType(QuizContentRenderer),
          matchesGoldenFile('goldens/quiz_content_text.png'),
        );
      });
    });

    testWidgets('renders LaTeX formulas correctly', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: QuizContentRenderer(
                content: r'다음 수식을 계산하세요: $$ E = mc^2 $$ 그리고 복잡한 인라인 $ \sqrt{a^2 + b^2} $ 도 포함합니다.',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(QuizContentRenderer),
          matchesGoldenFile('goldens/quiz_content_math.png'),
        );
      });
    });

    testWidgets('renders multiple blocks with image correctly', (WidgetTester tester) async {
      final complexContent = [
        {'type': 'text', 'content': '이미지를 보고 수종을 맞추세요.'},
        {'type': 'image', 'content': 'https://example.com/tree.jpg'},
        {'type': 'text', 'content': '힌트: 상록침엽수림'},
      ];

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: QuizContentRenderer(content: complexContent),
            ),
          ),
        );

        // 이미지 로딩용 프레임 펌핑
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(QuizContentRenderer),
          matchesGoldenFile('goldens/quiz_content_blocks.png'),
        );
      });
    });
  });
}
