import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import 'edit_profile_screen.dart';
import 'find_teammates_screen.dart';
import 'team_formation_screen.dart';
import 'skill_improvement_screen.dart';
import 'fyp_ideas_screen.dart';
import 'find_supervisor_screen.dart';
import 'student_requests_tab.dart';
import '../chat/chats_tab.dart';

const _pageBg = Color(0xFFF6F9FE);

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _index = 0;
  late final Stream<StudentProfile> _stream;

  @override
  void initState() {
    super.initState();
    _stream =
        ProfileService().watch(FirebaseAuth.instance.currentUser!.uid);
  }

  Widget _navItem(IconData icon, int i) {
    final selected = _index == i;
    return GestureDetector(
      onTap: () => setState(() => _index = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon,
            size: 27,
            color: selected ? AppColors.primary : const Color(0xFFA9B4C8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StudentProfile>(
      stream: _stream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            backgroundColor: _pageBg,
            body: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        final p = snap.data!;
        final tabs = <Widget>[
          _HomeTab(profile: p),
          const StudentRequestsTab(),
          const ChatsTab(isSupervisor: false),
          _ProfileTab(profile: p),
        ];
        return Scaffold(
          backgroundColor: _pageBg,
          body: IndexedStack(index: _index, children: tabs),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home_rounded, 0),
                  _navItem(Icons.assignment_rounded, 1),
                  _navItem(Icons.chat_bubble_rounded, 2),
                  _navItem(Icons.person_rounded, 3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------- HOME TAB ----------------
class _HomeTab extends StatelessWidget {
  final StudentProfile profile;
  const _HomeTab({required this.profile});

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.10),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  Widget _ring(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(0.12), width: 2),
    ),
  );

  Widget _stat(IconData icon, String number, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(number,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF7A88A5), fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _action(BuildContext context, IconData icon, String title,
      String subtitle, String step,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ??
              () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title will be added in $step'))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7468EE), AppColors.primaryDark],
                ),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF7A88A5), fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  color: AppColors.primary, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = profile.name.trim().split(' ').first;
    final complete = profile.completion;

    return Container(
      color: _pageBg,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- PURPLE HEADER (sirf upar) ----------
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7468EE), AppColors.primaryDark],
                ),
                borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(38)),
              ),
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(38)),
                child: Stack(
                  children: [
                    Positioned(top: -70, right: -60, child: _ring(230)),
                    Positioned(top: -20, right: -110, child: _ring(210)),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.hub_rounded,
                                    color: Colors.white, size: 30),
                                const Spacer(),
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    first.isEmpty
                                        ? '?'
                                        : first[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Text('Hi $first',
                                style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              complete < 100
                                  ? 'Complete your profile to get matches'
                                  : 'Your profile is complete',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8)),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text('My Profile',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17)),
                                      ),
                                      Text('$complete%',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 17)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.fypArea.isEmpty
                                        ? 'Add your details to get recommendations'
                                        : profile.fypArea,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 14),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: complete / 100,
                                      minHeight: 9,
                                      backgroundColor: Colors.white24,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- WHITE BODY ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy)),
                  const SizedBox(height: 14),
                  Row(children: [
                    _stat(Icons.code, '${profile.skills.length}', 'Skills'),
                    const SizedBox(width: 14),
                    _stat(Icons.favorite_border, '${profile.interests.length}',
                        'Interests'),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    _stat(Icons.work_outline, '${profile.experiences.length}',
                        'Experience'),
                    const SizedBox(width: 14),
                    _stat(Icons.check_circle_outline, '$complete%', 'Complete'),
                  ]),
                  const SizedBox(height: 28),
                  const Text('Quick Actions',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy)),
                  const SizedBox(height: 14),
                  _action(
                    context,
                    Icons.groups_rounded,
                    'Find Teammates',
                    'AI-matched teammates for you',
                    'Step 6',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FindTeammatesScreen(me: profile)),
                    ),
                  ),
                  _action(
                    context,
                    Icons.diversity_3_rounded,
                    'Build My Team',
                    'Best balanced team for your FYP',
                    'Step 7',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TeamFormationScreen(me: profile)),
                    ),
                  ),
                  _action(
                    context,
                    Icons.lightbulb_rounded,
                    'FYP Ideas',
                    '4-5 ideas based on your skills',
                    'Step 8',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FypIdeasScreen(profile: profile)),
                    ),
                  ),
                  _action(context, Icons.person_search_rounded,
                      'Find Supervisor', 'Best supervisor for your team',
                      'Step 9'),
                  _action(
                    context,
                    Icons.trending_up_rounded,
                    'Skill Improvement',
                    'Skills you should learn',
                    'Step 7',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              SkillImprovementScreen(profile: profile)),
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

// ---------------- PLACEHOLDER TAB ----------------
class _SoonTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _SoonTab(
      {required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _pageBg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 52, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              Text(title,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
              const SizedBox(height: 8),
              Text(text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF7A88A5))),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- PROFILE TAB ----------------
class _ProfileTab extends StatelessWidget {
  final StudentProfile profile;
  const _ProfileTab({required this.profile});

  Widget _section(String title, Widget child) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.navy)),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );

  Widget _chips(List<String> items) => items.isEmpty
      ? const Text('Not added yet',
      style: TextStyle(color: Color(0xFF7A88A5)))
      : Wrap(
    spacing: 8,
    runSpacing: 8,
    children: items
        .map((e) => Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(e,
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13)),
    ))
        .toList(),
  );

  String _val(String v) => v.isEmpty ? 'Not set' : v;

  @override
  Widget build(BuildContext context) {
    final initial =
    profile.name.isEmpty ? '?' : profile.name[0].toUpperCase();
    return Container(
      color: _pageBg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary,
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 12),
              Text(profile.name,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
              Text('CMS ${profile.cms}',
                  style: const TextStyle(color: Color(0xFF7A88A5))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profile'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(profile: profile)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(16),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      onPressed: () => AuthService().logout(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _section(
                  'About',
                  Text(profile.about.isEmpty ? 'Not added yet' : profile.about,
                      style: const TextStyle(color: AppColors.navy))),
              _section('Skills', _chips(profile.skills)),
              _section('Interests', _chips(profile.interests)),
              _section(
                'Preferences',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FYP Area: ${_val(profile.fypArea)}'),
                    const SizedBox(height: 4),
                    Text('Preferred Role: ${_val(profile.preferredRole)}'),
                    const SizedBox(height: 4),
                    Text('Availability: ${_val(profile.availability)}'),
                  ],
                ),
              ),
              _section(
                'Experience',
                profile.experiences.isEmpty
                    ? const Text('Not added yet',
                    style: TextStyle(color: Color(0xFF7A88A5)))
                    : Column(
                  children: profile.experiences
                      .map((e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.work_outline,
                        color: AppColors.primary),
                    title: Text(e.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700)),
                    subtitle: Text([
                      e.type,
                      e.organization,
                      e.duration
                    ].where((s) => s.isNotEmpty).join(' • ')),
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}