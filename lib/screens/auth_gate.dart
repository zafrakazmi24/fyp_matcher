import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'student/student_home.dart';
import 'supervisor/supervisor_home.dart';
import 'welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Widget _loader() => const Scaffold(
    body: Center(
        child: CircularProgressIndicator(color: AppColors.primary)),
  );

  Widget _problem(String text) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AuthService().logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loader();
        final user = snap.data;
        if (user == null) return const WelcomeScreen();

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, s) {
            if (s.hasError) {
              return _problem(
                  'Could not load your account.\nCheck Firestore rules and internet.\n\n${s.error}');
            }
            if (s.connectionState == ConnectionState.waiting) return _loader();
            if (!s.hasData || !s.data!.exists) {
              // Signup ke dauran doc likhne mein thori der lag sakti hai
              return FutureBuilder(
                future: Future.delayed(const Duration(seconds: 4)),
                builder: (context, f) {
                  if (f.connectionState != ConnectionState.done) {
                    return _loader();
                  }
                  return _problem(
                      'Your account data was not found. Please logout and sign up again.');
                },
              );
            }
            final role = s.data!.data()!['role'];
            return role == 'student'
                ? const StudentHome()
                : const SupervisorHome();
          },
        );
      },
    );
  }
}