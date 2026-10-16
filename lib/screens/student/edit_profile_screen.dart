import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/student_profile.dart';
import '../../services/nlp_service.dart';
import '../../services/profile_service.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/chip_input.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  final StudentProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _about;
  late List<String> _skills;
  late List<String> _interests;
  late List<Experience> _exps;
  String? _fypArea;
  String? _role;
  String? _availability;
  bool _saving = false;

  // NLP suggestions
  bool _analysed = false;
  List<String> _sugSkills = [];
  List<String> _sugInterests = [];
  String? _sugArea;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _about = TextEditingController(text: p.about);
    _skills = [...p.skills];
    _interests = [...p.interests];
    _exps = [...p.experiences];
    _fypArea = p.fypArea.isEmpty ? null : p.fypArea;
    _role = p.preferredRole.isEmpty ? null : p.preferredRole;
    _availability = p.availability.isEmpty ? null : p.availability;
  }

  @override
  void dispose() {
    _about.dispose();
    super.dispose();
  }

  // ---------------- NLP ----------------
  bool _has(List<String> list, String s) =>
      list.any((x) => x.toLowerCase() == s.toLowerCase());

  void _analyse() {
    FocusScope.of(context).unfocus();
    final text = [
      _about.text,
      ..._exps.expand((e) => [e.title, e.organization]),
    ].join('. ');

    final r = NlpService.analyze(text);
    setState(() {
      _analysed = true;
      _sugSkills = r.skills.where((s) => !_has(_skills, s)).toList();
      _sugInterests =
          r.interests.where((s) => !_has(_interests, s)).toList();
      _sugArea = _fypArea == null ? r.suggestedArea : null;
    });
  }

  void _addSkill(String s) => setState(() {
    _skills = [..._skills, s];
    _sugSkills.remove(s);
  });

  void _addInterest(String s) => setState(() {
    _interests = [..._interests, s];
    _sugInterests.remove(s);
  });

  void _addAll() => setState(() {
    _skills = [..._skills, ..._sugSkills];
    _interests = [..._interests, ..._sugInterests];
    _sugSkills = [];
    _sugInterests = [];
  });

  void _applyArea() => setState(() {
    _fypArea = _sugArea;
    _sugArea = null;
  });

  Widget _sugChip(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    ),
  );

  Widget _sugLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
            fontSize: 13)),
  );

  Widget _suggestionPanel() {
    final nothing =
        _sugSkills.isEmpty && _sugInterests.isEmpty && _sugArea == null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: nothing
          ? const Text(
        'No new skills or interests found. Try writing in more detail, '
            'e.g. "I know Flutter, Firebase and Python. I am interested in AI and mobile apps."',
        style: TextStyle(color: AppColors.navy),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('AI found these in your text',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
              ),
              if (_sugSkills.isNotEmpty || _sugInterests.isNotEmpty)
                TextButton(
                    onPressed: _addAll, child: const Text('Add all')),
            ],
          ),
          if (_sugSkills.isNotEmpty) ...[
            _sugLabel('Skills (tap to add)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sugSkills
                  .map((s) => _sugChip(s, () => _addSkill(s)))
                  .toList(),
            ),
          ],
          if (_sugInterests.isNotEmpty) ...[
            _sugLabel('Interests (tap to add)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sugInterests
                  .map((s) => _sugChip(s, () => _addInterest(s)))
                  .toList(),
            ),
          ],
          if (_sugArea != null) ...[
            _sugLabel('Suggested FYP area'),
            _sugChip(_sugArea!, _applyArea),
          ],
        ],
      ),
    );
  }

  // ---------------- EXPERIENCE ----------------
  InputDecoration _dialogDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.bgLight,
  );

  Future<void> _addExperience() async {
    final title = TextEditingController();
    final org = TextEditingController();
    final dur = TextEditingController();
    String type = experienceTypes.first;

    final result = await showDialog<Experience>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Add Experience',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: _dialogDecoration('Type'),
                  items: experienceTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setD(() => type = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                    controller: title,
                    decoration: _dialogDecoration('Role / Title')),
                const SizedBox(height: 10),
                TextField(
                    controller: org,
                    decoration: _dialogDecoration('Company / Organization')),
                const SizedBox(height: 10),
                TextField(
                    controller: dur,
                    decoration: _dialogDecoration('Duration (e.g. 2 months)')),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (title.text.trim().isEmpty) return;
                Navigator.pop(
                  ctx,
                  Experience(
                    type: type,
                    title: title.text.trim(),
                    organization: org.text.trim(),
                    duration: dur.text.trim(),
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null) setState(() => _exps.add(result));
  }

  // ---------------- SAVE ----------------
  Future<void> _save() async {
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one skill.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final p = widget.profile;
      await ProfileService().save(StudentProfile(
        uid: p.uid,
        name: p.name,
        cms: p.cms,
        about: _about.text.trim(),
        fypArea: _fypArea ?? '',
        preferredRole: _role ?? '',
        availability: _availability ?? '',
        skills: _skills,
        interests: _interests,
        experiences: _exps,
      ));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Edit Profile',
      subtitle: 'The better your profile, the better your matches.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('About You',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.navy)),
          ),
          TextField(
            controller: _about,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
              'Write freely, e.g. "I know Flutter and Firebase and I enjoy building AI-based apps."',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _analyse,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Analyse with AI'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_analysed) _suggestionPanel(),
          ChipInput(
            label: 'Skills',
            hint: 'e.g. Flutter, Python (comma separated)',
            icon: Icons.code,
            items: _skills,
            onChanged: (v) => setState(() => _skills = v),
          ),
          ChipInput(
            label: 'Interests',
            hint: 'e.g. AI, Mobile Apps',
            icon: Icons.favorite_border,
            items: _interests,
            onChanged: (v) => setState(() => _interests = v),
          ),
          AppDropdown(
            label: 'Preferred FYP Area',
            hint: 'Select area',
            icon: Icons.lightbulb_outline,
            items: fypAreas,
            value: _fypArea,
            onChanged: (v) => setState(() => _fypArea = v),
          ),
          AppDropdown(
            label: 'Preferred Role',
            hint: 'Select role',
            icon: Icons.engineering_outlined,
            items: preferredRoles,
            value: _role,
            onChanged: (v) => setState(() => _role = v),
          ),
          AppDropdown(
            label: 'Availability',
            hint: 'Select availability',
            icon: Icons.schedule,
            items: availabilityOptions,
            value: _availability,
            onChanged: (v) => setState(() => _availability = v),
          ),
          Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('Experience (Internship / Professional)',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy)),
                ),
              ),
              IconButton(
                onPressed: _addExperience,
                icon: const Icon(Icons.add_circle,
                    color: AppColors.primary, size: 30),
              ),
            ],
          ),
          if (_exps.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16),
              child: Text('No experience added yet.',
                  style: TextStyle(color: Color(0xFF5B6B8C))),
            ),
          ..._exps.asMap().entries.map((entry) {
            final e = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.work_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            style:
                            const TextStyle(fontWeight: FontWeight.w800)),
                        Text(
                          [e.type, e.organization, e.duration]
                              .where((s) => s.isNotEmpty)
                              .join(' • '),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF5B6B8C)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: () =>
                        setState(() => _exps.removeAt(entry.key)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          PrimaryButton(
              text: 'Save Profile', loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}