import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/geo_art.dart';
import 'auth/role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.42,
                  width: double.infinity,
                  child: const Center(
                    child: AspectRatio(aspectRatio: 1, child: GeoArt()),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Find your perfect\nFYP team',
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'AI-based teammate, idea and supervisor '
                      'recommendations in a single platform.',
                  style: TextStyle(fontSize: 15, color: AppColors.navy),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 34, vertical: 20),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}