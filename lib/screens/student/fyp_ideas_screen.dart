import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/student_profile.dart';
import '../../services/idea_service.dart';
import '../../widgets/primary_button.dart';

const _bg = Color(0xFFF6F9FE);
const _muted = Color(0xFF7A88A5);
const _green = Color(0xFF22B573);
const _orange = Color(0xFFF5A623);

class FypIdeasScreen extends StatefulWidget {
  final StudentProfile profile;
  const FypIdeasScreen({super.key, required this.profile});

  @override
  State<FypIdeasScreen> createState() => _FypIdeasScreenState();
}

class _FypIdeasScreenState extends State<FypIdeasScreen> {
  static const _any = 'Any area';
  late String _domain;
  List<IdeaMatch> _results = [];
  final Set<String> _shown = {};
  bool _generated = false;

  @override
  void initState() {
    super.initState();
    final area = widget.profile.fypArea;
    _domain = fypAreas.contains(area) ? area : _any;
    if (widget.profile.skills.isNotEmpty ||
        widget.profile.interests.isNotEmpty) {
      _generate();
    }
  }

  void _generate({bool fresh = true}) {
    if (fresh) _shown.clear();
    final domain = _domain == _any ? null : _domain;
    var r = IdeaService.recommend(widget.profile,
        domain: domain, exclude: _shown);
    if (r.length < 3 && _shown.isNotEmpty) {
      _shown.clear();
      r = IdeaService.recommend(widget.profile, domain: domain);
    }
    _shown.addAll(r.map((e) => e.idea.id));
    setState(() {
      _results = r;
      _generated = true;
    });
  }

  Color _scoreColor(int s) {
    if (s >= 75) return _green;
    if (s >= 55) return AppColors.primary;
    if (s >= 35) return _orange;
    return const Color(0xFFB8C4D6);
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Beginner':
        return _green;
      case 'Intermediate':
        return _orange;
      default:
        return const Color(0xFFE5484D);
    }
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

  Widget _chip(String text,
      {Color? color, IconData? icon, bool filled = false}) {
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

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(t,
        style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppColors.navy)),
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
                  const Text('FYP Ideas',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Real-world project ideas that fit your profile',
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
  Widget _controls() {
    final p = widget.profile;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preferred domain',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _domain,
            isExpanded: true,
            borderRadius: BorderRadius.circular(18),
            decoration: const InputDecoration(
              filled: true,
              fillColor: _bg,
              prefixIcon:
              Icon(Icons.lightbulb_outline, color: AppColors.primary),
            ),
            items: [_any, ...fypAreas]
                .map((e) => DropdownMenuItem(
                value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _domain = v!),
          ),
          if (p.skills.isNotEmpty) ...[
            _title('Your skills'),
            Wrap(
                spacing: 6,
                runSpacing: 6,
                children: p.skills.take(8).map((e) => _chip(e)).toList()),
          ],
          if (p.interests.isNotEmpty) ...[
            _title('Your interests'),
            Wrap(
                spacing: 6,
                runSpacing: 6,
                children: p.interests.take(8).map((e) => _chip(e)).toList()),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
              text: _generated ? 'Regenerate Ideas' : 'Generate Ideas',
              onPressed: _generate),
        ],
      ),
    );
  }

  // ---------------- IDEA CARD ----------------
  Widget _ideaCard(int rank, IdeaMatch m) {
    final i = m.idea;
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 34,
                width: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$rank',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: AppColors.navy)),
                    const SizedBox(height: 4),
                    Text(m.label,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: _scoreColor(m.score))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ring(m.score),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip(i.area, icon: Icons.category_outlined),
              _chip(i.difficulty, color: _difficultyColor(i.difficulty)),
            ],
          ),
          _title('The problem'),
          Text(i.problem, style: const TextStyle(height: 1.4)),
          _title('Why it suits you'),
          ...m.reasons.map((r) => Padding(
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
          _title('Key features'),
          ...i.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle,
                      size: 6, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(f)),
              ],
            ),
          )),
          _title('Skills for this project'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...m.haveSkills.map((s) =>
                  _chip(s, color: _green, icon: Icons.check_circle)),
              ...m.partialSkills
                  .map((s) => _chip(s, color: AppColors.primary, icon: Icons.trending_up)),
              ...m.needSkills
                  .map((s) => _chip(s, color: _orange, icon: Icons.school_outlined)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Green: you have it  •  Purple: related skill  •  Orange: to learn',
              style: TextStyle(fontSize: 11, color: _muted)),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final empty = p.skills.isEmpty && p.interests.isEmpty;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: empty
                ? _note(Icons.person_outline, 'Complete your profile first',
                'Add your skills and interests in Edit Profile so the AI can suggest ideas that fit you.')
                : ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              children: [
                _controls(),
                if (_generated && _results.isEmpty)
                  _note(Icons.search_off, 'No ideas found',
                      'Try another domain or add more skills.'),
                for (var k = 0; k < _results.length; k++)
                  _ideaCard(k + 1, _results[k]),
                if (_results.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => _generate(fresh: false),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Show different ideas'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}