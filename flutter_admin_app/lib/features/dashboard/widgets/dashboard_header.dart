import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onSignOut;
  final VoidCallback onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.onSignOut,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    const surfaceDark = Color(0xFF1A2E24);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.logout,
            onTap: onSignOut,
            surfaceDark: surfaceDark,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '관리자 대시보드',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tree Master System',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          _buildNotificationButton(
            onTap: onNotificationTap,
            surfaceDark: surfaceDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color surfaceDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white70, size: 18),
      ),
    );
  }

  Widget _buildNotificationButton({
    required VoidCallback onTap,
    required Color surfaceDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Colors.white70,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: surfaceDark, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
