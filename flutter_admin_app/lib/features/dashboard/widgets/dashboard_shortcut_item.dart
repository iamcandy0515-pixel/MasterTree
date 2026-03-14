import 'package:flutter/material.dart';

class DashboardShortcutItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final VoidCallback onTap;
  final Color color;

  const DashboardShortcutItem({
    super.key,
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.onTap,
    this.color = const Color(0xFF2BEE8C),
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subLabel,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[700], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
