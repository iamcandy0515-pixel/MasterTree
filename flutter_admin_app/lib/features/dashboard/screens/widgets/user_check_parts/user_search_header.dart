import 'package:flutter/material.dart';

class UserSearchHeader extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final Function(int) onTabTap;
  final Color primaryColor;
  final Color surfaceColor;

  const UserSearchHeader({
    super.key,
    required this.onSearchChanged,
    required this.onTabTap,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          onTap: onTabTap,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.white24,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: '대기 중'),
            Tab(text: '승인됨'),
            Tab(text: '거절됨'),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 14),
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: '사용자 이름 또는 이메일 검색',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: primaryColor.withOpacity(0.5), size: 20),
              filled: true,
              fillColor: surfaceColor.withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryColor.withOpacity(0.4), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

