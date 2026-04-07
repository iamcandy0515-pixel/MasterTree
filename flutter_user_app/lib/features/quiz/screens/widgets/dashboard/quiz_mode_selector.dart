import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import '../../quiz_solver_screen.dart';

class QuizModeSelector extends StatelessWidget {
  const QuizModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '모드 선택',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _ModeButton(
          title: '랜덤 기출문제 풀기',
          desc: '무작위로 10문제를 뽑아 스피디하게 풉니다.',
          icon: Icons.shuffle,
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext _) => const QuizSolverScreen(mode: 'random'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ModeButton(
          title: '취약점 집중 공략',
          desc: '내가 가장 많이 틀렸던 유형 위주로 학습합니다.',
          icon: Icons.healing,
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext _) => const QuizSolverScreen(mode: 'weakness'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ModeButton(
          title: '나의 오답 노트',
          desc: '이전에 틀렸던 문제를 다시 확인하고 복습합니다.',
          icon: Icons.menu_book,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('오답 노트 화면으로 이동합니다..')),
            );
          },
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.desc,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white30,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
