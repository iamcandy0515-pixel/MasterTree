import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/user_detail_stats_screen.dart';

class UserStatsListItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onTap;

  const UserStatsListItem({super.key, required this.user, this.onTap});

  static const Color primaryColor = Color(0xFF2BEE8C);

  @override
  Widget build(BuildContext context) {
    final String name = user['name'] ?? '알 수 없음';
    final String email = user['email'] ?? '';
    final String status = user['status'] == 'admin' ? '[관]' : '[사]';
    final int treeCount = user['tree_quiz_count'] ?? 0;
    final int examCount = user['exam_quiz_count'] ?? 0;

    final lastLoginStr = user['last_login']?.toString();
    String timeStr = '-';
    if (lastLoginStr != null) {
      final lastLogin = DateTime.tryParse(lastLoginStr)?.toLocal();
      if (lastLogin != null) {
        timeStr = DateFormat('MM.dd HH:mm').format(lastLogin);
      }
    }

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                UserDetailStatsScreen(userId: user['id'], userName: name),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: primaryColor.withAlpha(25),
        child: const Icon(Icons.person, color: primaryColor, size: 20),
      ),
      title: Row(
        children: [
          Text(
            '$status $name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '(수목: $treeCount건, 기출: $examCount건)',
              style: const TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        email,
        style: const TextStyle(color: Colors.white30, fontSize: 12),
      ),
      trailing: Text(
        timeStr,
        style: const TextStyle(color: Colors.white24, fontSize: 11),
      ),
    );
  }
}
