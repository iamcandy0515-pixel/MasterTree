import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/log_check_viewmodel.dart';

class LogCheckScreen extends StatelessWidget {
  const LogCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LogCheckViewModel(),
      child: const _LogCheckContent(),
    );
  }
}

class _LogCheckContent extends StatelessWidget {
  const _LogCheckContent();

  static const backgroundDark = Color(0xFF0D1117);
  static const surfaceDark = Color(0xFF161B22);
  static const accentGreen = Color(0xFF3FB950);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LogCheckViewModel>();

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        title: const Text(
          '시스템 로그 확인',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: viewModel.clearLogs,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: viewModel.refreshLogs,
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: viewModel.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: accentGreen),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.white10,
                      child: const Text(
                        'TERMINAL - SYSTEM LOGS',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.logs.length,
                        itemBuilder: (context, index) {
                          final log = viewModel.logs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: '[${log['time']}] ',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    text: '${log['type']} ',
                                    style: TextStyle(
                                      color: log['color'] as Color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ': ${log['msg']}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.white.withValues(alpha: 0.02),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chevron_right,
                            color: accentGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ready for commands...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
