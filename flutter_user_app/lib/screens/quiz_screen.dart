import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/models/quiz_model.dart';
import 'package:flutter_user_app/screens/quiz_result_screen.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';
import 'package:flutter_user_app/controllers/quiz_controller.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/core/widgets/fullscreen_image_viewer.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizController _controller = QuizController();

  @override
  void initState() {
    super.initState();
    _controller.initialize(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // 화면 이탈 시 남은 학습 결과 동기화 (네트워크 상황에 따라 보장되지는 않을 수 있음)
    ApiService.syncPendingAttempts();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final question = _controller.currentQuestion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // 뒤로가기 시 보류 중인 결과 동기화 시도
        await ApiService.syncPendingAttempts();
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildMainImage(question.imageUrl),
                        const SizedBox(height: 16),
                        _buildHintSectionWithButton(question),
                        const SizedBox(height: 16),
                        _buildOptions(question),
                        const SizedBox(height: 100), // Footer space
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_controller.showHintMessage) _buildFloatingHint(),
            if (_controller.showDescription)
              _buildFloatingDescription(question),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.8),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      // 뒤로가기 버튼 클릭 시에도 동기화 트리거
                      ApiService.syncPendingAttempts();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                  ),
                ),
                const Text(
                  '수목 식별 학습',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      // 통계 화면 진입 전 동기화 완료 대기
                      await ApiService.syncPendingAttempts();
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) =>
                                const UserStatsScreen(initialIndex: 1),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '퀴즈통계',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _controller.totalQuestions > 0
                      ? _controller.solvedCount / _controller.totalQuestions
                      : 0.0,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImage(String imageUrl) {
    return Center(
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullscreenImageViewer(
                    imageUrl: imageUrl,
                    title: '수목 식별 이미지',
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.park, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          '이미지를 불러올 수 없습니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.125,
                    widthFactor: 1.0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(color: Colors.black.withValues(alpha: 0.35)),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.25,
                    widthFactor: 1.0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHintSectionWithButton(QuizQuestion question) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              '힌트 보기',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lightbulb,
                    size: 10,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_controller.viewedHintsCount}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildHintItem(Icons.energy_savings_leaf, '잎'),
                    _buildHintItem(Icons.texture, '수피'),
                    _buildHintItem(Icons.local_florist, '꽃'),
                    _buildHintItem(Icons.eco, '열매/겨울눈'),
                    _buildHintItem(Icons.category, '대표'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (_controller.selectedAnswer != null &&
                !_controller.isCorrect) ...[
              TextButton.icon(
                onPressed: () => _controller.retry(() => setState(() {})),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('다시 풀기'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (_controller.selectedAnswer != null &&
                _controller.isCorrect) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  if (_controller.hasNext) {
                    _controller.nextQuestion(() => setState(() {}));
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuizResultScreen(
                          correctCount: _controller.correctCount,
                          accumulatedHintCount:
                              _controller.accumulatedHintCount,
                          solvedCount: _controller.solvedCount,
                        ),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _controller.hasNext ? '다음문제' : '결과보기',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildHintItem(IconData icon, String label) {
    bool isActive = _controller.selectedHint == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _controller.selectHint(label, () => setState(() {})),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                boxShadow: isActive ? [AppDesign.glowPrimary] : null,
              ),
              child: Icon(
                icon,
                color: isActive ? AppColors.backgroundDark : Colors.white54,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingHint() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.35,
      left: 20,
      right: 20,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_controller.selectedHint} 힌트',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _controller.hideHintMessage(() => setState(() {})),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _controller.currentHintText,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDescription(QuizQuestion question) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.3,
      left: 20,
      right: 20,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 400),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '정답입니다!',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _controller.hideDescription(() => setState(() {})),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  question.description,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(QuizQuestion question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final label = question.options[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildOptionItem(index, label),
        );
      }),
    );
  }

  Widget _buildOptionItem(int index, String label) {
    final isSelected = _controller.selectedAnswer == index;
    final isCorrect = _controller.currentQuestion.correctAnswerIndex == index;
    final showCorrect = isSelected && isCorrect;
    final showWrong = isSelected && !_controller.isCorrect;

    return GestureDetector(
      onTap: _controller.selectedAnswer == null
          ? () => _controller.selectAnswer(index, () => setState(() {}))
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: showCorrect
              ? AppColors.primary.withValues(alpha: 0.12)
              : showWrong
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: showCorrect
                ? AppColors.primary.withValues(alpha: 0.3)
                : showWrong
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.03),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: showCorrect
                      ? AppColors.primary
                      : showWrong
                      ? Colors.redAccent
                      : Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: showCorrect || showWrong
                      ? FontWeight.bold
                      : FontWeight.w400,
                ),
              ),
            ),
            if (showCorrect)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 18)
            else if (showWrong)
              Icon(Icons.cancel, color: Colors.red.withValues(alpha: 0.8), size: 18),
          ],
        ),
      ),
    );
  }
}
