import '../core/skill_groups.dart';
import '../models/student_profile.dart';

class SkillAdvice {
  final String skill;
  final String reason;
  final String priority; // High / Medium / Low
  final String group;
  final String tip;

  SkillAdvice({
    required this.skill,
    required this.reason,
    required this.priority,
    required this.group,
    required this.tip,
  });
}

class SkillReport {
  final Map<String, int> strengths; // group -> skills ki tadad
  final List<String> missingGroups;
  final List<SkillAdvice> advice;
  final String area;

  SkillReport({
    required this.strengths,
    required this.missingGroups,
    required this.advice,
    required this.area,
  });
}

class SkillAdvisorService {
  static SkillReport analyse(StudentProfile p) {
    final owned = p.skills.map(canonicalSkill).toList();
    final ownedLower = owned.map((e) => e.toLowerCase()).toSet();

    // ----- Strengths -----
    final counts = <String, int>{};
    for (final g in skillGroups.keys) {
      final c = groupCount(owned, g);
      if (c > 0) counts[g] = c;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final strengths = Map<String, int>.fromEntries(sorted);

    // ----- Area ke missing groups -----
    final required = p.fypArea.isEmpty
        ? <String>[]
        : (areaRequirements[p.fypArea] ?? areaRequirements['Other']!);
    final missingGroups =
    required.where((g) => !hasGroup(owned, g)).toList();

    final advice = <SkillAdvice>[];
    final added = <String>{};

    void add(String skill, String reason, String priority, String group) {
      final l = skill.toLowerCase();
      if (added.contains(l) || ownedLower.contains(l)) return;
      added.add(l);
      advice.add(SkillAdvice(
        skill: skill,
        reason: reason,
        priority: priority,
        group: group,
        tip: groupTips[group] ?? groupTips['General']!,
      ));
    }

    // 1) FYP area ke liye zaroori lekin profile mein nahi
    for (final g in missingGroups) {
      final starters = groupStarters[g] ?? const <String>[];
      final pick = starters.firstWhere(
              (s) => !ownedLower.contains(s.toLowerCase()),
          orElse: () => '');
      if (pick.isNotEmpty) {
        add(pick,
            'Your ${p.fypArea} FYP needs $g skills, but your profile has none yet.',
            'High', g);
      }
    }

    // 2) Jo skills aate hain un se related skills
    final related = <String, List<String>>{};
    for (final s in owned) {
      for (final r in relatedSkills[s] ?? const <String>[]) {
        if (!ownedLower.contains(r.toLowerCase())) {
          related.putIfAbsent(r, () => []).add(s);
        }
      }
    }
    final relSorted = related.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    for (final e in relSorted) {
      add(
        e.key,
        'Pairs well with your ${e.value.take(2).join(' and ')} skills.',
        e.value.length >= 2 ? 'High' : 'Medium',
        groupOfSkill(e.key) ?? 'General',
      );
    }

    // 3) Team kaam ke liye
    add('Git', 'Version control is essential when a team works on one FYP codebase.',
        'Low', 'DevOps / Cloud');

    const rank = {'High': 0, 'Medium': 1, 'Low': 2};
    advice.sort((a, b) => rank[a.priority]!.compareTo(rank[b.priority]!));

    return SkillReport(
      strengths: strengths,
      missingGroups: missingGroups,
      advice: advice.take(8).toList(),
      area: p.fypArea,
    );
  }
}