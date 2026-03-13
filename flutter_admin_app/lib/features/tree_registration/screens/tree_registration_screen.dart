import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tree_registration_viewmodel.dart';
import 'widgets/registration_header.dart';
import 'widgets/basic_info_section.dart';
import 'widgets/smart_tag_image_section.dart';
import 'widgets/quiz_distractor_section.dart';

class TreeRegistrationScreen extends StatelessWidget {
  const TreeRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeRegistrationViewModel(),
      child: const _RegistrationScaffold(),
    );
  }
}

class _RegistrationScaffold extends StatelessWidget {
  const _RegistrationScaffold();

  static const backgroundDark = Color(0xFF0A0C08);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: const [
                  BasicInfoSection(),
                  SizedBox(height: 32),
                  SmartTagImageSection(),
                  SizedBox(height: 32),
                  QuizDistractorSection(),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
