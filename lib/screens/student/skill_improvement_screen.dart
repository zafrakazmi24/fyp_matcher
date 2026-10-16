import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/student_profile.dart';
import '../../services/skill_advisor_service.dart';

const _bg = Color(0xFFF6F9FE);
const _muted = Color(0xFF7A88A5);

class SkillImprovementScreen extends StatelessWidget {
  final StudentProfile profile;
  const SkillImprovementScreen({super.key, required this.profile});

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return const Color(0xFFE5484D);
      case 'Medium':
        return const Color(0xFFF5A623);
      default:
        return _muted;
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

  Widget _header(BuildContext context) => Container(
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
                  const Text('Skill Improvement',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Skills you should learn for your FYP',
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

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(title,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navy)),
  );

  Widget _adviceCard(SkillAdvice a) {
    final c = _priorityColor(a.priority);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(a.skill,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${a.priority} priority',
                    style: TextStyle(
                        color: c,
                        fontWeight: FontWeight.w800,
                        fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(a.group,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
          const SizedBox(height: 10),
          Text(a.reason),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tips_and_updates_outlined,
                  size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(a.tip,
                    style: const TextStyle(fontSize: 13, color: _muted)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = SkillAdvisorService.analyse(profile);
    final maxCount =
    r.strengths.values.isEmpty ? 1 : r.strengths.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: profile.skills.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Add your skills in Edit Profile first, then the AI can tell you what to improve.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted),
                ),
              ),
            )
                : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              children: [
                if (profile.fypArea.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 22),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Tip: choose a Preferred FYP Area in Edit Profile to get advice specific to your project.',
                      style: TextStyle(color: AppColors.navy),
                    ),
                  ),

                _section('Your strengths'),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _cardDeco(),
                  child: Column(
                    children: r.strengths.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(e.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: e.value / maxCount,
                                  minHeight: 9,
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.10),
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 28,
                              child: Text('${e.value}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: _muted, fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (r.missingGroups.isNotEmpty) ...[
                  _section('Gaps for ${r.area}'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: r.missingGroups
                        .map((g) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5484D)
                            .withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(g,
                          style: const TextStyle(
                              color: Color(0xFFE5484D),
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ))
                        .toList(),
                  ),
                ],

                _section('Recommended skills to learn'),
                if (r.advice.isEmpty)
                  const Text(
                      'Great! Your skills already cover everything we look for.',
                      style: TextStyle(color: _muted))
                else
                  ...r.advice.map(_adviceCard),
              ],
            ),
          ),
        ],
      ),
    );
  }
}