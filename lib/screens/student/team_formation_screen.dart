import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/student_profile.dart';
import '../../models/team_suggestion.dart';
import '../../services/team_service.dart';
import '../../widgets/primary_button.dart';

const _bg = Color(0xFFF6F9FE);
const _muted = Color(0xFF7A88A5);
const _green = Color(0xFF22B573);
const _red = Color(0xFFE5484D);

class TeamFormationScreen extends StatefulWidget {
  final StudentProfile me;
  const TeamFormationScreen({super.key, required this.me});

  @override
  State<TeamFormationScreen> createState() => _TeamFormationScreenState();
}

class _TeamFormationScreenState extends State<TeamFormationScreen> {
  int _size = 3;
  late String _area;
  Future<List<TeamSuggestion>>? _future;

  @override
  void initState() {
    super.initState();
    _area = widget.me.fypArea.isNotEmpty ? widget.me.fypArea : fypAreas.first;
  }

  void _form() {
    setState(() {
      _future = TeamService().suggest(me: widget.me, size: _size, area: _area);
    });
  }

  Color _scoreColor(int s) {
    if (s >= 75) return _green;
    if (s >= 55) return AppColors.primary;
    if (s >= 35) return const Color(0xFFF5A623);
    return const Color(0xFFB8C4D6);
  }

  BoxDecoration _cardDeco() => BoxDecoration(
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

  Widget _ring(int score, {double size = 64}) {
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

  Widget _chip(String text, {Color? color, IconData? icon, bool filled = false}) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? c : c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: filled ? Colors.white : c),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : c)),
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Text(t,
        style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.navy)),
  );

  Widget _bar(String label, int value, int max) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
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
          width: 50,
          child: Text('$value/$max',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: _muted)),
        ),
      ],
    ),
  );

  // ---------------- HEADER ----------------
  Widget _header() => Container(
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
                  const Text('Build My Team',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('AI forms a balanced team with the skills your FYP needs',
                      style:
                      TextStyle(color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // ---------------- CONTROLS ----------------
  Widget _controls() => Container(
    padding: const EdgeInsets.all(18),
    decoration: _cardDeco(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('FYP Area',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.navy)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _area,
          isExpanded: true,
          borderRadius: BorderRadius.circular(18),
          decoration: InputDecoration(
            filled: true,
            fillColor: _bg,
            prefixIcon:
            const Icon(Icons.lightbulb_outline, color: AppColors.primary),
          ),
          items: fypAreas
              .map((e) => DropdownMenuItem(
              value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) => setState(() => _area = v!),
        ),
        const SizedBox(height: 18),
        const Text('Team Size',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.navy)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [2, 3, 4, 5].map((n) {
            final sel = _size == n;
            return ChoiceChip(
              label: Text('$n members'),
              selected: sel,
              showCheckmark: false,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : AppColors.navy),
              backgroundColor: _bg,
              selectedColor: AppColors.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onSelected: (_) => setState(() => _size = n),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        PrimaryButton(text: 'Form Best Team', onPressed: _form),
      ],
    ),
  );

  Widget _note(IconData icon, String title, String text) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 44, color: AppColors.primary),
        ),
        const SizedBox(height: 14),
        Text(title,
            style: const TextStyle(
                fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted)),
      ],
    ),
  );

  // ---------------- TEAM CARD ----------------
  Widget _teamCard(int rank, TeamSuggestion t) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Option $rank',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 20)),
                        if (rank == 1) ...[
                          const SizedBox(width: 8),
                          _chip('Best', color: _green, filled: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(t.label,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _scoreColor(t.score))),
                  ],
                ),
              ),
              _ring(t.score),
            ],
          ),

          _title('Team members'),
          ...t.members.asMap().entries.map((entry) {
            final m = entry.value;
            final isMe = entry.key == 0;
            final unique = t.uniqueGroups[m.uid] ?? [];
            final all = t.contributions[m.uid] ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                    isMe ? AppColors.accent : AppColors.primary,
                    child: Text(
                      m.name.isEmpty ? '?' : m.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isMe ? '${m.name} (You)' : m.name,
                            style:
                            const TextStyle(fontWeight: FontWeight.w800)),
                        if (m.preferredRole.isNotEmpty)
                          Text(m.preferredRole,
                              style: const TextStyle(
                                  color: _muted, fontSize: 12)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...unique.map((g) => _chip(g,
                                filled: true, icon: Icons.star_rounded)),
                            ...all
                                .where((g) => !unique.contains(g))
                                .map((g) => _chip(g)),
                            if (all.isEmpty)
                              const Text('No key skill area for this FYP yet',
                                  style:
                                  TextStyle(color: _muted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const Text('Filled chip = only this member covers that area',
              style: TextStyle(color: _muted, fontSize: 11)),

          _title('Skill coverage for $_area'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...t.coveredGroups.map((g) =>
                  _chip(g, color: _green, icon: Icons.check_circle)),
              ...t.missingGroups
                  .map((g) => _chip(g, color: _red, icon: Icons.cancel)),
            ],
          ),

          if (t.missingGroups.isNotEmpty) ...[
            _title('Missing skills'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _red.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: t.missingGroups.map((g) {
                  final starters = groupStartersFor(g);
                  final who = t.fillers[g] ?? [];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No one in this team covers $g',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('Someone should learn: $starters',
                            style: const TextStyle(fontSize: 12)),
                        if (who.isNotEmpty)
                          Text('Students who have it: ${who.join(', ')}',
                              style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          _title('Why this team?'),
          ...t.reasons.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle,
                    size: 17, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(child: Text(r)),
              ],
            ),
          )),

          _title('Score breakdown'),
          _bar('Coverage', t.coverageScore, 40),
          _bar('Roles', t.roleScore, 20),
          _bar('Interests', t.interestScore, 20),
          _bar('Availability', t.availabilityScore, 10),
          _bar('Experience', t.experienceScore, 10),
        ],
      ),
    );
  }

  String groupStartersFor(String g) {
    const m = {
      'Frontend': 'Flutter or React',
      'Backend': 'Node.js or Firebase',
      'Database': 'SQL or MongoDB',
      'AI / ML': 'Machine Learning or Scikit-learn',
      'Data & Analytics': 'Pandas or Data Analysis',
      'UI/UX Design': 'Figma or UI/UX Design',
      'Testing & QA': 'Software Testing',
      'Documentation & PM': 'Technical Writing or Agile/Scrum',
      'DevOps / Cloud': 'Git or Docker',
      'Security': 'Cyber Security or Networking',
      'Hardware / IoT': 'Arduino or IoT',
      'Game Engine': 'Unity',
    };
    return m[g] ?? g;
  }

  // ---------------- RESULTS ----------------
  Widget _results() {
    if (_future == null) return const SizedBox.shrink();
    return FutureBuilder<List<TeamSuggestion>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (snap.hasError) {
          return _note(Icons.error_outline, 'Something went wrong',
              '${snap.error}');
        }
        final teams = snap.data ?? [];
        if (teams.isEmpty) {
          return _note(Icons.groups_outlined, 'No teammates available',
              'No other student has completed a profile yet. Ask your friends to add their skills.');
        }
        return Column(
          children: [
            for (var i = 0; i < teams.length; i++) _teamCard(i + 1, teams[i]),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomplete = widget.me.skills.isEmpty;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: incomplete
                ? _note(Icons.person_outline, 'Complete your profile first',
                'Add your skills in Edit Profile so the AI can build the right team for you.')
                : ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              children: [_controls(), _results()],
            ),
          ),
        ],
      ),
    );
  }
}