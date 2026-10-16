import 'package:flutter/material.dart';
import '../core/theme.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  Widget _ring(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(0.12), width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7468EE), AppColors.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -70, right: -70, child: _ring(260)),
            Positioned(top: -20, right: -110, child: _ring(220)),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.75))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(36)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}