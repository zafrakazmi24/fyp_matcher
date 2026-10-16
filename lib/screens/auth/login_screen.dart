import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';
import 'signup_screen.dart';
import '../auth_gate.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'student' ya 'supervisor'
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await AuthService().login(
      role: widget.role,
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.role == 'student';
    return AuthScaffold(
      title: isStudent ? 'Student Login' : 'Supervisor Login',
      subtitle: 'Welcome back! Please sign in.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _email,
              label: 'Email',
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            AppTextField(
              controller: _password,
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (v) =>
              (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
                text: 'Login', loading: _loading, onPressed: _submit),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SignupScreen(role: widget.role)),
                  ),
                  child: const Text('Sign up',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}