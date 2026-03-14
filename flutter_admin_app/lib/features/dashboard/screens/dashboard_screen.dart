import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_admin_app/features/auth/screens/login_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/user_check_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/notification_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/statistics_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/settings_screen.dart';

// Modular Widgets
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stats_section.dart';
import '../widgets/dashboard_exam_tab.dart';
import '../widgets/dashboard_tree_tab.dart';
import '../widgets/dashboard_bottom_nav.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardStats();
    });
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _handleSignOut() async {
    final vm = context.read<DashboardViewModel>();
    final success = await vm.signOut();
    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    const primaryColor = Color(0xFF2BEE8C);
    const backgroundDark = Color(0xFF102219);

    return Scaffold(
      backgroundColor: backgroundDark,
      bottomNavigationBar: vm.isLoading
          ? null
          : DashboardBottomNav(
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) _navigateTo(const StatisticsScreen());
                if (index == 2) _navigateTo(const UserCheckScreen());
                if (index == 3) _navigateTo(const SettingsScreen());
              },
            ),
      body: SafeArea(
        bottom: false,
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  DashboardHeader(
                    onSignOut: _handleSignOut,
                    onNotificationTap: () =>
                        _navigateTo(const NotificationScreen()),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  const DashboardStatsSection(),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            indicatorColor: primaryColor,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(
                                icon: Icon(Icons.description, size: 20),
                                text: '기출문제',
                              ),
                              Tab(
                                icon: Icon(Icons.nature, size: 20),
                                text: '수목관리',
                              ),
                            ],
                          ),
                          const Expanded(
                            child: TabBarView(
                              children: [
                                DashboardExamTab(),
                                DashboardTreeTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
