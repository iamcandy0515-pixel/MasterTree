import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/auth/viewmodels/login_viewmodel.dart';
import 'package:flutter_admin_app/features/dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel()..loadCredentials(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Flag to ensure we only pre-fill once
  bool _initialized = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to credentials loading
    final vm = context.watch<LoginViewModel>();

    // One-time population of controllers when credentials are loaded
    if (!_initialized && vm.savedEmail.isNotEmpty) {
      _emailController.text = vm.savedEmail;
      _passwordController.text = vm.savedPassword;
      _initialized = true;
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.forest, size: 80, color: Color(0xFFCCFF00)),
              const SizedBox(height: 24),
              const Text(
                'MasterTree Admin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: vm.isLoading ? null : () => _attemptLogin(context),
                child: vm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('LOGIN'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: vm.isLoading ? null : () => _attemptSignUp(context),
                child: const Text('TEST SIGNUP (Dev Only)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _attemptLogin(BuildContext context) async {
    // Use read to avoid rebuilds during async
    final vm = context.read<LoginViewModel>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final success = await vm.signIn(email, password);
      // Check mounted before using context
      if (context.mounted && success) {
        Navigator.pushReplacement<dynamic, dynamic>(
          context,
          MaterialPageRoute<dynamic>(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _attemptSignUp(BuildContext context) async {
    final vm = context.read<LoginViewModel>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final success = await vm.signUp(email, password);
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Please login.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }
}
