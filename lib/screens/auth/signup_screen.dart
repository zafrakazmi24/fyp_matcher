import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';
import 'login_screen.dart';
import '../auth_gate.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _field1 = TextEditingController(); // student: CMS | supervisor: designation
  final _field2 = TextEditingController(); // supervisor: department
  bool _loading = false;

  bool get _isStudent => widget.role == 'student';

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _field1, _field2]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final extra = _isStudent
        ? {'cmsNumber': _field1.text.trim()}
        : {
      'designation': _field1.text.trim(),
      'department': _field2.text.trim(),
    };
    final error = await AuthService().signUp(
      role: widget.role,
      name: _name.text,
      email: _email.text,
      password: _password.text,
      extra: extra,
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
    return AuthScaffold(
      title: _isStudent ? 'Student Sign Up' : 'Supervisor Sign Up',
      subtitle: 'Create your account to get started.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _name,
              label: 'Full Name',
              hint: 'Your full name',
              icon: Icons.person_outline,
              validator: _required,
            ),
            if (_isStudent)
              AppTextField(
                controller: _field1,
                label: 'CMS Number',
                hint: 'e.g. 56030',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                validator: _required,
              )
            else ...[
              AppTextField(
                controller: _field1,
                label: 'Designation',
                hint: 'e.g. Lecturer, Teaching Fellow',
                icon: Icons.work_outline,
                validator: _required,
              ),
              AppTextField(
                controller: _field2,
                label: 'Department',
                hint: 'e.g. Faculty of Computing',
                icon: Icons.apartment_outlined,
                validator: _required,
              ),
            ],
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
              hint: 'Minimum 6 characters',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (v) =>
              (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ),
            AppTextField(
              controller: _confirm,
              label: 'Confirm Password',
              hint: 'Re-enter password',
              icon: Icons.lock_reset,
              isPassword: true,
              validator: (v) =>
              v != _password.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 8),
            PrimaryButton(
                text: 'Create Account',
                loading: _loading,
                onPressed: _submit),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LoginScreen(role: widget.role)),
                  ),
                  child: const Text('Login',
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