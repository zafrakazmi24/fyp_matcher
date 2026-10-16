import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/student_profile.dart';
import '../../models/supervision_request.dart';
import '../../services/request_service.dart';
import '../../services/supervisor_matching_service.dart';
import '../../widgets/primary_button.dart';

const _bg = Color(0xFFF6F9FE);
const _muted = Color(0xFF7A88A5);
const _green = Color(0xFF22B573);
const _orange = Color(0xFFF5A623);
const _red = Color(0xFFE5484D);

class FindSupervisorScreen extends StatefulWidget {
  final StudentProfile me;
  const FindSupervisorScreen({super.key, required this.me});

  @override
  State<FindSupervisorScreen> createState() => _FindSupervisorScreenState();
}

class _FindSupervisorScreenState extends State<FindSupervisorScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  late String _area;
  List<StudentProfile> _teammates = [];
  Future<List<SupervisorMatch>>? _future;
  List<SupervisionRequest> _myRequests = [];
  StreamSubscription<List<SupervisionRequest>>? _sub;
  bool _sending = false;

  List<StudentProfile> get _team => [widget.me, ..._teammates];

  @override
  void initState() {
    super.initState();
    _area = fypAreas.contains(widget.me.fypArea)
        ? widget.me.fypArea
        : fypAreas.first;
    _sub = RequestService().watchForStudent(widget.me.uid).listen((l) {
      if (mounted) setState(() => _myRequests = l);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  SupervisionRequest? get _accepted {
    for (final r in _myRequests) {
      if (r.isAccepted) return r;
    }
    return null;
  }

  SupervisionRequest? _requestFor(String supUid) {
    for (final r in _myRequests) {
      if (r.supervisorUid == supUid && r.studentUid == widget.me.uid) return r;
    }
    return null;
  }

  void _find() {
    FocusScope.of(context).unfocus();
    setState(() {
      _future = SupervisorMatchingService().find(
        team: _team,
        area: _area,
        projectText: '${_title.text}. ${_desc.text}',
      );
    });
  }

  Future<void> _pickTeam() async {
    final res = await showModalBottomSheet<List<StudentProfile>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _TeamPicker(myUid: widget.me.uid, selected: _teammates),
    );
    if (res != null) setState(() => _teammates = res);
  }

  Future<void> _askAndSend(SupervisorMatch m) async {
    final msg = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Request ${m.profile.name}',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team: ${_team.map((e) => e.name).join(', ')}',
                style: const TextStyle(fontSize: 12, color: _muted)),
            const SizedBox(height: 12),
            TextField(
              controller: msg,
              maxLines: 4,
              decoration: const InputDecoration(
                filled: true,
                fillColor: _bg,
                hintText: 'Short message to the supervisor (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Send')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _sending = true);
    final err = await RequestService().send(
      leader: widget.me,
      team: _team,
      sup: m.profile,
      projectTitle: _title.text.trim(),
      area: _area,
      message: msg.text.trim(),
      score: m.score,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'Request sent to ${m.profile.name}')));
  }

  // ---------------- helpers ----------------
  Color _scoreColor(int s) {
    if (s >= 75) return _green;
    if (s >= 55) return AppColors.primary;
    if (s >= 35) return _orange;
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

  Widget _bar(String label, int value, int max) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 100,
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

  Widget _title2(String t) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Text(t,
        style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.navy)),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
    child: Text(t,
        style: const TextStyle(
            fontWeight: FontWeight.w800, color: AppColors.navy)),
  );

  // ---------------- header ----------------
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
                  const Text('Find Supervisor',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('The best supervisor for your team and project',
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

  // ---------------- controls ----------------
  Widget _controls() => Container(
    padding: const EdgeInsets.all(18),
    decoration: _cardDeco(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Your team'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip('${widget.me.name} (You)',
                filled: true, icon: Icons.person),
            ..._teammates.map((p) => _chip(p.name, icon: Icons.person_outline)),
            GestureDetector(
              onTap: _pickTeam,
              child: _chip(
                  _teammates.isEmpty ? 'Add teammates' : 'Edit team',
                  color: AppColors.accent,
                  icon: Icons.group_add_outlined),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _label('FYP area'),
        DropdownButtonFormField<String>(
          value: _area,
          isExpanded: true,
          borderRadius: BorderRadius.circular(18),
          decoration: const InputDecoration(
            filled: true,
            fillColor: _bg,
            prefixIcon:
            Icon(Icons.lightbulb_outline, color: AppColors.primary),
          ),
          items: fypAreas
              .map((e) => DropdownMenuItem(
              value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) => setState(() => _area = v!),
        ),
        const SizedBox(height: 16),
        _label('Project title (optional)'),
        TextField(
          controller: _title,
          decoration: const InputDecoration(
            filled: true,
            fillColor: _bg,
            hintText: 'e.g. Healthcare Appointment App',
          ),
        ),
        const SizedBox(height: 16),
        _label('Project description (optional)'),
        TextField(
          controller: _desc,
          maxLines: 3,
          decoration: const InputDecoration(
            filled: true,
            fillColor: _bg,
            hintText:
            'e.g. A Flutter app with Firebase and an AI chatbot for patients',
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 6, bottom: 14),
          child: Text(
            'The AI reads this text to find extra skills and interests.',
            style: TextStyle(fontSize: 12, color: _muted),
          ),
        ),
        PrimaryButton(text: 'Find Supervisors', onPressed: _find),
      ],
    ),
  );

  Widget _acceptedBanner(SupervisionRequest r) => Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _green.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _green.withOpacity(0.4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.verified, color: _green),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Your team is supervised by ${r.supervisorName}. You cannot send more requests.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  // ---------------- card ----------------
  Widget _card(int rank, SupervisorMatch m) {
    final s = m.profile;
    final req = _requestFor(s.uid);
    return GestureDetector(
      onTap: () => _showDetails(m),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
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
                      Text(
                        [s.designation, s.department]
                            .where((e) => e.isNotEmpty)
                            .join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(m.label,
                          style: TextStyle(
                              color: _scoreColor(m.score),
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                    ],
                  ),
                ),
                _ring(m.score),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (m.isFull)
                  _chip('Full', color: _red, icon: Icons.block)
                else
                  _chip('${m.slotsLeft} slot${m.slotsLeft > 1 ? 's' : ''} left',
                      color: _green, icon: Icons.event_available),
                if (req != null)
                  _chip(
                      req.status == 'pending'
                          ? 'Requested'
                          : req.status == 'accepted'
                          ? 'Accepted'
                          : 'Declined',
                      color: req.status == 'accepted'
                          ? _green
                          : req.status == 'pending'
                          ? _orange
                          : _red,
                      filled: true),
                ...m.matchedSkills.take(3).map((e) => _chip(e)),
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
            const Align(
              alignment: Alignment.centerRight,
              child: Text('See details and request',
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

  // ---------------- details sheet ----------------
  Widget _sheetButton(SupervisorMatch m, BuildContext sheetCtx) {
    final req = _requestFor(m.profile.uid);
    String text = 'Send Request';
    bool enabled = true;

    if (_accepted != null) {
      text = 'Your team already has a supervisor';
      enabled = false;
    } else if (req != null && req.status == 'pending') {
      text = 'Request pending';
      enabled = false;
    } else if (req != null && req.status == 'accepted') {
      text = 'Accepted';
      enabled = false;
    } else if (m.isFull) {
      text = 'No slots left';
      enabled = false;
    } else if (req != null && req.status == 'rejected') {
      text = 'Send Request Again';
    }

    return PrimaryButton(
      text: text,
      loading: _sending,
      onPressed: enabled
          ? () {
        Navigator.pop(sheetCtx);
        _askAndSend(m);
      }
          : null,
    );
  }

  void _showDetails(SupervisorMatch m) {
    final s = m.profile;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
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
                        Text(
                            [s.designation, s.department]
                                .where((e) => e.isNotEmpty)
                                .join(' • '),
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
              _title2('Why this supervisor?'),
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
              _title2('Suitability breakdown'),
              _bar('Expertise', m.expertiseScore, 35),
              _bar('Research', m.interestScore, 25),
              _bar('FYP area', m.areaScore, 25),
              _bar('Availability', m.availabilityScore, 15),
              if (s.expertise.isNotEmpty) ...[
                _title2('Technical expertise'),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: s.expertise
                        .map((e) => _chip(e,
                        filled: m.matchedSkills.any(
                                (x) => x.toLowerCase() == e.toLowerCase())))
                        .toList()),
              ],
              if (s.researchInterests.isNotEmpty) ...[
                _title2('Research interests'),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                    s.researchInterests.map((e) => _chip(e)).toList()),
              ],
              if (s.preferredAreas.isNotEmpty) ...[
                _title2('Preferred FYP areas'),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: s.preferredAreas
                        .map((e) => _chip(e,
                        color: e == _area ? _green : AppColors.primary,
                        filled: e == _area))
                        .toList()),
              ],
              if (s.about.isNotEmpty) ...[
                _title2('About'),
                Text(s.about),
              ],
              _title2('Availability'),
              Text(s.availability.isEmpty ? 'Not set' : s.availability),
              const SizedBox(height: 4),
              Text(m.isFull
                  ? 'All ${s.maxTeams} team slots are taken'
                  : '${m.slotsLeft} of ${s.maxTeams} team slots free'),
              const SizedBox(height: 26),
              _sheetButton(m, sheetCtx),
            ],
          ),
        ),
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

  Widget _results() {
    if (_future == null) return const SizedBox.shrink();
    return FutureBuilder<List<SupervisorMatch>>(
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
          return _note(
              Icons.error_outline, 'Something went wrong', '${snap.error}');
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return _note(Icons.person_search_outlined, 'No supervisors yet',
              'No supervisor has completed a profile yet. Ask supervisors to add their expertise.');
        }
        return Column(
          children: [
            for (var i = 0; i < list.length; i++) _card(i + 1, list[i]),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomplete =
        widget.me.skills.isEmpty && widget.me.interests.isEmpty;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: incomplete
                ? _note(Icons.person_outline, 'Complete your profile first',
                'Add your skills and interests in Edit Profile so the AI can find the right supervisor.')
                : ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              children: [
                if (_accepted != null) _acceptedBanner(_accepted!),
                _controls(),
                _results(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= TEAM PICKER =================
class _TeamPicker extends StatefulWidget {
  final String myUid;
  final List<StudentProfile> selected;
  const _TeamPicker({required this.myUid, required this.selected});

  @override
  State<_TeamPicker> createState() => _TeamPickerState();
}

class _TeamPickerState extends State<_TeamPicker> {
  late Future<List<StudentProfile>> _future;
  late List<StudentProfile> _sel;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _sel = [...widget.selected];
    _future = FirebaseFirestore.instance
        .collection('student_profiles')
        .get()
        .then((s) => s.docs
        .map((d) => StudentProfile.fromMap(d.data()))
        .where((p) => p.uid != widget.myUid)
        .toList());
  }

  bool _isSel(StudentProfile p) => _sel.any((x) => x.uid == p.uid);

  void _toggle(StudentProfile p) {
    setState(() {
      if (_isSel(p)) {
        _sel.removeWhere((x) => x.uid == p.uid);
      } else if (_sel.length < 4) {
        _sel.add(p);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A team can have up to 5 members.')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Select your teammates',
                  style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _q = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search by name or CMS',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<StudentProfile>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  final list = (snap.data ?? [])
                      .where((p) =>
                  p.name.toLowerCase().contains(_q) ||
                      p.cms.toLowerCase().contains(_q))
                      .toList();
                  if (list.isEmpty) {
                    return const Center(
                        child: Text('No students found',
                            style: TextStyle(color: _muted)));
                  }
                  return ListView(
                    children: list
                        .map((p) => CheckboxListTile(
                      value: _isSel(p),
                      onChanged: (_) => _toggle(p),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity:
                      ListTileControlAffinity.trailing,
                      title: Text(p.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        'CMS ${p.cms}${p.skills.isEmpty ? '' : ' • ${p.skills.take(3).join(', ')}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                        .toList(),
                  );
                },
              ),
            ),
            PrimaryButton(
              text: 'Done (${_sel.length} selected)',
              onPressed: () => Navigator.pop(context, _sel),
            ),
          ],
        ),
      ),
    );
  }
}