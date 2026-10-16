import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/supervisor_profile.dart';
import '../../services/auth_service.dart';
import '../../services/supervisor_service.dart';
import 'edit_supervisor_profile_screen.dart';
import 'supervisor_requests_tab.dart';

const _bg = Color(0xFFF6F9FE);

class SupervisorHome extends StatefulWidget {
  const SupervisorHome({super.key});

  @override
  State<SupervisorHome> createState() => _SupervisorHomeState();
}

class _SupervisorHomeState extends State<SupervisorHome> {
  int _index = 0;
  late final Stream<SupervisorProfile> _stream;

  @override
  void initState() {
    super.initState();
    _stream =
        SupervisorService().watch(FirebaseAuth.instance.currentUser!.uid);
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
    return StreamBuilder<SupervisorProfile>(
      stream: _stream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            backgroundColor: _bg,
            body: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        final p = snap.data!;
        final tabs = <Widget>[
          _HomeTab(
              profile: p, onOpenRequests: () => setState(() => _index = 1)),
          const SupervisorRequestsTab(),
          const _SoonTab(
              icon: Icons.chat_bubble_outline,
              title: 'Chat',
              text: 'Private chat with students will be added in Step 10.'),
          _ProfileTab(profile: p),
        ];
        return Scaffold(
          backgroundColor: _bg,
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
                  _navItem(Icons.mark_email_unread_rounded, 1),
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
  final SupervisorProfile profile;
  final VoidCallback onOpenRequests;
  const _HomeTab({required this.profile, required this.onOpenRequests});

  BoxDecoration _card() => BoxDecoration(
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
      decoration: _card(),
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
      String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: _card(),
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
      color: _bg,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- PURPLE HEADER ----------
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
                            Text('Hello, $first',
                                style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              [profile.designation, profile.department]
                                  .where((s) => s.isNotEmpty)
                                  .join(' • '),
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
                                    complete < 100
                                        ? 'Complete your profile so students can find you'
                                        : 'Your profile is complete',
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
                    _stat(Icons.code, '${profile.expertise.length}',
                        'Expertise'),
                    const SizedBox(width: 14),
                    _stat(Icons.science_outlined,
                        '${profile.researchInterests.length}', 'Research'),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    _stat(Icons.category_outlined,
                        '${profile.preferredAreas.length}', 'FYP Areas'),
                    const SizedBox(width: 14),
                    _stat(Icons.groups_outlined, '${profile.maxTeams}',
                        'Max Teams'),
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
                    Icons.edit_note_rounded,
                    'Edit Profile',
                    'Update expertise, interests and availability',
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              EditSupervisorProfileScreen(profile: profile)),
                    ),
                  ),
                  _action(
                    context,
                    Icons.mark_email_unread_rounded,
                    'Student Requests',
                    'Accept or reject supervision requests',
                    onOpenRequests,
                  ),
                  _action(
                    context,
                    Icons.chat_bubble_rounded,
                    'Messages',
                    'Reply to student queries',
                        () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Messages will be added in Step 10'))),
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
      color: _bg,
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
  final SupervisorProfile profile;
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

  @override
  Widget build(BuildContext context) {
    final initial =
    profile.name.isEmpty ? '?' : profile.name[0].toUpperCase();
    return Container(
      color: _bg,
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
              Text(
                [profile.designation, profile.department]
                    .where((s) => s.isNotEmpty)
                    .join(' • '),
                style: const TextStyle(color: Color(0xFF7A88A5)),
              ),
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
                            builder: (_) => EditSupervisorProfileScreen(
                                profile: profile)),
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
              _section('Technical Expertise', _chips(profile.expertise)),
              _section('Research Interests', _chips(profile.researchInterests)),
              _section('Preferred FYP Areas', _chips(profile.preferredAreas)),
              _section(
                'Availability',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.availability.isEmpty
                        ? 'Not set'
                        : profile.availability),
                    const SizedBox(height: 4),
                    Text('Can supervise up to ${profile.maxTeams} teams'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}