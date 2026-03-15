import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

// Modular Widgets
import 'widgets/add_parts/add_tree_header.dart';
import 'widgets/add_parts/add_tree_basic_info_section.dart';
import 'widgets/add_parts/add_tree_image_manager.dart';
import 'widgets/add_parts/add_tree_quiz_config.dart';
import 'widgets/add_parts/add_tree_mobile_preview.dart';

class AddTreeScreen extends StatelessWidget {
  final Tree? tree;
  const AddTreeScreen({super.key, this.tree});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddTreeViewModel(tree),
      child: const _AddTreeContent(),
    );
  }
}

class _AddTreeContent extends StatefulWidget {
  const _AddTreeContent();

  @override
  State<_AddTreeContent> createState() => _AddTreeContentState();
}

class _AddTreeContentState extends State<_AddTreeContent> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: NeoTheme.darkTheme.scaffoldBackgroundColor,
      endDrawer: const Drawer(
        width: 450,
        backgroundColor: Color(0xFF0A0C08),
        child: AddTreeMobilePreview(),
      ),
      appBar: AddTreeHeader(
        scaffoldKey: _scaffoldKey,
        formKey: _formKey,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          children: [
            const SizedBox(height: 16),
            AddTreeBasicInfoSection(formKey: _formKey),
            const SizedBox(height: 20),
            const AddTreeImageManager(),
            const SizedBox(height: 20),
            const AddTreeQuizConfig(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
