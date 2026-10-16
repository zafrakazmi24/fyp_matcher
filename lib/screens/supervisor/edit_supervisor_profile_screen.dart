import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/supervisor_profile.dart';
import '../../services/supervisor_service.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/chip_input.dart';
import '../../widgets/primary_button.dart';

class EditSupervisorProfileScreen extends StatefulWidget {
  final SupervisorProfile profile;
  const EditSupervisorProfileScreen({super.key, required this.profile});

  @override
  State<EditSupervisorProfileScreen> createState() =>
      _EditSupervisorProfileScreenState();
}

class _EditSupervisorProfileScreenState
    extends State<EditSupervisorProfileScreen> {
  late final TextEditingController _about;
  late List<String> _expertise;
  late List<String> _research;
  late List<String> _areas;
  String? _availability;
  late int _maxTeams;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _about = TextEditingController(text: p.about);
    _expertise = [...p.expertise];
    _research = [...p.researchInterests];
    _areas = [...p.preferredAreas];
    _availability = p.availability.isEmpty ? null : p.availability;
    _maxTeams = p.maxTeams;
  }

  @override
  void dispose() {
    _about.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_expertise.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please add at least one technical expertise.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final p = widget.profile;
      await SupervisorService().save(SupervisorProfile(
        uid: p.uid,
        name: p.name,
        designation: p.designation,
        department: p.department,
        about: _about.text.trim(),
        expertise: _expertise,
        researchInterests: _research,
        preferredAreas: _areas,
        availability: _availability ?? '',
        maxTeams: _maxTeams,
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

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Edit Profile',
      subtitle: 'Students are matched to you using this information.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('About',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.navy)),
          ),
          TextField(
            controller: _about,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
              'Brief introduction, e.g. "I supervise AI and mobile app projects."',
            ),
          ),
          const SizedBox(height: 20),
          ChipInput(
            label: 'Technical Expertise',
            hint: 'e.g. Python, Flutter (comma separated)',
            icon: Icons.code,
            items: _expertise,
            onChanged: (v) => setState(() => _expertise = v),
          ),
          ChipInput(
            label: 'Research Interests',
            hint: 'e.g. NLP, Recommender Systems',
            icon: Icons.science_outlined,
            items: _research,
            onChanged: (v) => setState(() => _research = v),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text('Preferred FYP Areas',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.navy)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fypAreas.map((a) {
              final selected = _areas.contains(a);
              return FilterChip(
                label: Text(a),
                selected: selected,
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.navy,
                ),
                backgroundColor: Colors.white,
                selectedColor: AppColors.primary,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                onSelected: (v) => setState(() {
                  v ? _areas.add(a) : _areas.remove(a);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          AppDropdown(
            label: 'Availability',
            hint: 'Select availability',
            icon: Icons.schedule,
            items: availabilityOptions,
            value: _availability,
            onChanged: (v) => setState(() => _availability = v),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Maximum Teams I Can Supervise',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.navy)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: AppColors.primary, size: 30),
                  onPressed: _maxTeams > 1
                      ? () => setState(() => _maxTeams--)
                      : null,
                ),
                Text('$_maxTeams',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: AppColors.primary, size: 30),
                  onPressed: _maxTeams < 10
                      ? () => setState(() => _maxTeams++)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
              text: 'Save Profile', loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}