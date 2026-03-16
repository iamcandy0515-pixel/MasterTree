import 'package:flutter/material.dart';
import '../../../../../../core/utils/format_utils.dart';
import 'user_action_buttons.dart';

class UserCardItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final String currentStatus;
  final Color primaryColor;
  final Function(String) onApprove;
  final Function(String) onReject;
  final Function(String, String) onDelete;

  const UserCardItem({
    super.key,
    required this.user,
    required this.currentStatus,
    required this.primaryColor,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = user['name'] ?? '사용자';
    final initial = name.replaceAll(RegExp(r'\[.*?\]\s*'), '').isNotEmpty
        ? name.replaceAll(RegExp(r'\[.*?\]\s*'), '')[0]
        : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A2A2A).withOpacity(0.8),
            const Color(0xFF1A1A1A).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: primaryColor.withOpacity(0.03),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user['email'] ?? ''}${user['phone'] != null ? ' | ${FormatUtils.formatPhone(user['phone'])}' : ''}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(user['role'] ?? 'User', primaryColor),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white24,
                  size: 18,
                ),
                onPressed: () => onDelete(user['id']!, name),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                   '최근 활동: ${user['lastLogin']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              UserActionButtons(
                status: currentStatus,
                onApprove: () => onApprove(user['id']!),
                onReject: () => onReject(user['id']!),
                primaryColor: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

