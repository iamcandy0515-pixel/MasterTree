import 'package:flutter/material.dart';

class LookalikeNavControls extends StatelessWidget {
  final VoidCallback onScrollLeft;
  final VoidCallback onScrollRight;

  const LookalikeNavControls({
    super.key,
    required this.onScrollLeft,
    required this.onScrollRight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.touch_app, color: Colors.white54, size: 14),
                SizedBox(width: 8),
                Text(
                  '가로로 보기',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _NavButton(
            icon: Icons.chevron_left,
            onTap: onScrollLeft,
            color: const Color(0xFF80F20D),
          ),
          const SizedBox(width: 8),
          _NavButton(
            icon: Icons.chevron_right,
            onTap: onScrollRight,
            color: const Color(0xFF80F20D),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _NavButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 20),
      ),
    );
  }
}
