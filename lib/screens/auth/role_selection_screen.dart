import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Widget _roleCard(BuildContext context,
      {required String role,
        required String title,
        required String desc,
        required IconData icon}) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => LoginScreen(role: role))),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7468EE), AppColors.primaryDark],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF5B6B8C))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgLight, AppColors.bg],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  icon: const Icon(Icons.arrow_back, color: AppColors.navy),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 28),
                const Text('Who are you?',
                    style:
                    TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Choose your role to continue',
                    style: TextStyle(fontSize: 15, color: Color(0xFF5B6B8C))),
                const SizedBox(height: 36),
                _roleCard(context,
                    role: 'student',
                    title: 'Student',
                    desc: 'Find teammates, FYP ideas and a supervisor',
                    icon: Icons.school_rounded),
                const SizedBox(height: 20),
                _roleCard(context,
                    role: 'supervisor',
                    title: 'Supervisor',
                    desc: 'Manage expertise and student requests',
                    icon: Icons.person_search_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}