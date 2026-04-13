import 'package:flutter/material.dart';
import '../../../../../../core/utils/format_utils.dart';
import 'user_action_buttons.dart';

class UserCardItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final String currentStatus;
  final Color primaryColor;
  final Function(String) onApprove;
  final Function(String) onReject;
  final Function(String) onPending;
  final Function(String, String) onDelete;

  final Function(String, Map<String, dynamic>) onUpdate;

  const UserCardItem({
    super.key,
    required this.user,
    required this.currentStatus,
    required this.primaryColor,
    required this.onApprove,
    required this.onReject,
    required this.onPending,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final String name = (user['name'] as String?) ?? '사용자';
    final String initial = name.replaceAll(RegExp(r'\[.*?\]\s*'), '').isNotEmpty
        ? name.replaceAll(RegExp(r'\[.*?\]\s*'), '')[0]
        : '?';
    final String? expiredAt = user['expiredAt'] as String?;

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
                      '${user['email'] as String? ?? ''}${user['phone'] != null ? ' | ${FormatUtils.formatPhone(user['phone'] as String)}' : ''}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(user['role'] as String? ?? 'User', primaryColor),
              if (user['isDuplicate'] == true) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 10),
                      SizedBox(width: 4),
                      Text(
                        '중복 가능성',
                        style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white24,
                  size: 18,
                ),
                onPressed: () => onDelete(user['id'] as String, name),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                       '최근 활동: ${user['lastLogin'] as String? ?? '정보 없음'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '만료일: ${_formatDateShort(expiredAt)}',
                          style: TextStyle(
                            color: _isExpired(expiredAt) ? Colors.redAccent : Colors.grey[400],
                            fontSize: 10,
                            fontWeight: _isExpired(expiredAt) ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Icon(Icons.edit_calendar_outlined, color: primaryColor, size: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              UserActionButtons(
                status: currentStatus,
                onApprove: () => onApprove(user['id'] as String),
                onReject: () => onReject(user['id'] as String),
                onPending: () => onPending(user['id'] as String),
                primaryColor: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateShort(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '무제한';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '형식 오류';
    }
  }

  bool _isExpired(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateTime.now().isAfter(date);
    } catch (e) {
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = (user['expiredAt'] != null)
        ? DateTime.parse(user['expiredAt'].toString()).toLocal()
        : now.add(const Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: primaryColor,
              onPrimary: Colors.black,
              surface: const Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onUpdate(user['id'] as String, <String, dynamic>{'expired_at': picked.toIso8601String()});
    }
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
