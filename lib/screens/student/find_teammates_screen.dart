import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/student_profile.dart';
import '../../models/teammate_match.dart';
import '../../services/matching_service.dart';

const _bg = Color(0xFFF6F9FE);
const _muted = Color(0xFF7A88A5);

class FindTeammatesScreen extends StatefulWidget {
  final StudentProfile me;
  const FindTeammatesScreen({super.key, required this.me});

  @override
  State<FindTeammatesScreen> createState() => _FindTeammatesScreenState();
}

class _FindTeammatesScreenState extends State<FindTeammatesScreen> {
  late Future<List<TeammateMatch>> _future;

  @override
  void initState() {
    super.initState();
    _future = MatchingService().findMatches(widget.me);
  }

  Future<void> _refresh() async {
    setState(() => _future = MatchingService().findMatches(widget.me));
    await _future;
  }

  Color _scoreColor(int s) {
    if (s >= 75) return const Color(0xFF22B573);
    if (s >= 55) return AppColors.primary;
    if (s >= 35) return const Color(0xFFF5A623);
    return const Color(0xFFB8C4D6);
  }

  Widget _ring(int score, {double size = 60}) {
    final c = _scoreColor(score);
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: c.withOpacity(0.15),
              color: c,
            ),
          ),
          Text('$score%',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.26,
                  color: AppColors.navy)),
        ],
      ),
    );
  }

  Widget _chip(String text, {bool strong = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: strong
          ? AppColors.primary
          : AppColors.primary.withOpacity(0.10),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: strong ? Colors.white : AppColors.primary)),
  );

  // ---------------- HEADER ----------------
  Widget _header(int count) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7468EE), AppColors.primaryDark],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 24, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Find Teammates',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    count == 0
                        ? 'AI-matched on skills, interests and experience'
                        : '$count students ranked for you',
                    style:
                    TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _empty(IconData icon, String title, String text) => Center(
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
            child: Icon(icon, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted)),
        ],
      ),
    ),
  );

  // ---------------- CARD ----------------
  Widget _card(TeammateMatch m) {
    final s = m.student;
    final c = _scoreColor(m.score);
    return GestureDetector(
      onTap: () => _showDetails(m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    s.name.isEmpty ? '?' : s.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: AppColors.navy)),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (s.preferredRole.isNotEmpty) s.preferredRole,
                          if (s.fypArea.isNotEmpty) s.fypArea,
                        ].join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(m.label,
                          style: TextStyle(
                              color: c,
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                    ],
                  ),
                ),
                _ring(m.score),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...m.complementarySkills.take(3).map((e) => _chip(e, strong: true)),
                ...m.sharedSkills.take(2).map((e) => _chip(e)),
              ],
            ),
            const SizedBox(height: 12),
            ...m.reasons.take(2).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(r,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.navy))),
                ],
              ),
            )),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('See full details',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DETAILS SHEET ----------------
  Widget _bar(String label, int value, int max) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: max == 0 ? 0 : value / max,
              minHeight: 9,
              backgroundColor: AppColors.primary.withOpacity(0.10),
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text('$value/$max',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: _muted)),
        ),
      ],
    ),
  );

  Widget _sheetTitle(String t) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Text(t,
        style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.navy)),
  );

  void _showDetails(TeammateMatch m) {
    final s = m.student;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _ring(m.score, size: 78),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800)),
                        Text('CMS ${s.cms}',
                            style: const TextStyle(color: _muted)),
                        const SizedBox(height: 4),
                        Text(m.label,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _scoreColor(m.score))),
                      ],
                    ),
                  ),
                ],
              ),
              _sheetTitle('Why this match?'),
              ...m.reasons.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 18, color: AppColors.accent),
                    const SizedBox(width: 10),
                    Expanded(child: Text(r)),
                  ],
                ),
              )),
              _sheetTitle('Score breakdown'),
              _bar('Skills', m.skillScore, 35),
              _bar('Interests', m.interestScore, 30),
              _bar('Experience', m.experienceScore, 15),
              _bar('Availability', m.availabilityScore, 10),
              _bar('Role', m.roleScore, 10),
              if (m.complementarySkills.isNotEmpty) ...[
                _sheetTitle('Skills they add to your team'),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: m.complementarySkills
                        .map((e) => _chip(e, strong: true))
                        .toList()),
              ],
              if (m.sharedSkills.isNotEmpty) ...[
                _sheetTitle('Skills you both have'),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: m.sharedSkills.map((e) => _chip(e)).toList()),
              ],
              if (s.interests.isNotEmpty) ...[
                _sheetTitle('Interests'),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: s.interests.map((e) => _chip(e)).toList()),
              ],
              if (s.experiences.isNotEmpty) ...[
                _sheetTitle('Experience'),
                ...s.experiences.map((e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.work_outline,
                      color: AppColors.primary),
                  title: Text(e.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text([e.type, e.organization, e.duration]
                      .where((x) => x.isNotEmpty)
                      .join(' • ')),
                )),
              ],
              if (s.about.isNotEmpty) ...[
                _sheetTitle('About'),
                Text(s.about),
              ],
              _sheetTitle('Preferences'),
              Text('FYP Area: ${s.fypArea.isEmpty ? 'Not set' : s.fypArea}'),
              const SizedBox(height: 4),
              Text(
                  'Preferred Role: ${s.preferredRole.isEmpty ? 'Not set' : s.preferredRole}'),
              const SizedBox(height: 4),
              Text(
                  'Availability: ${s.availability.isEmpty ? 'Not set' : s.availability}'),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final profileIncomplete = widget.me.skills.isEmpty;

    return Scaffold(
      backgroundColor: _bg,
      body: FutureBuilder<List<TeammateMatch>>(
        future: _future,
        builder: (context, snap) {
          final loading = snap.connectionState != ConnectionState.done;
          final matches = snap.data ?? [];

          Widget body;
          if (profileIncomplete) {
            body = _empty(Icons.person_outline, 'Complete your profile first',
                'Add your skills and interests in Edit Profile so the AI can find the right teammates for you.');
          } else if (loading) {
            body = const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          } else if (snap.hasError) {
            body = _empty(Icons.error_outline, 'Something went wrong',
                '${snap.error}');
          } else if (matches.isEmpty) {
            body = _empty(Icons.groups_outlined, 'No teammates yet',
                'No other student has completed a profile yet. Ask your friends to add their skills.');
          } else {
            body = RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                children: matches.map(_card).toList(),
              ),
            );
          }

          return Column(
            children: [
              _header(matches.length),
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}