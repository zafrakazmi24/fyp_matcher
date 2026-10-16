import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../core/skill_groups.dart';
import '../models/student_profile.dart';
import '../models/team_suggestion.dart';
import 'matching_service.dart';

class TeamService {
  final _db = FirebaseFirestore.instance;

  /// Chune hue size aur FYP area ke liye behtareen 3 teams.
  Future<List<TeamSuggestion>> suggest({
    required StudentProfile me,
    required int size,
    required String area,
  }) async {
    final snap = await _db.collection('student_profiles').get();
    final pool = snap.docs
        .map((d) => StudentProfile.fromMap(d.data()))
        .where((p) => p.uid != me.uid && p.skills.isNotEmpty)
        .toList();
    if (pool.isEmpty) return [];

    final need = min(size - 1, pool.length);

    // Aap ke sab se compatible 12 students
    final pairScore = {
      for (final p in pool) p.uid: MatchingService.score(me, p).score,
    };
    final ranked = [...pool]
      ..sort((a, b) => pairScore[b.uid]!.compareTo(pairScore[a.uid]!));
    final candidates = ranked.take(12).toList();

    final teams = <TeamSuggestion>[];
    for (final combo in _combos(candidates, need)) {
      teams.add(_evaluate([me, ...combo], area, pool));
    }
    teams.sort((a, b) => b.score.compareTo(a.score));
    return teams.take(3).toList();
  }

  List<List<StudentProfile>> _combos(List<StudentProfile> items, int k) {
    final result = <List<StudentProfile>>[];
    void go(int start, List<StudentProfile> cur) {
      if (cur.length == k) {
        result.add([...cur]);
        return;
      }
      for (var i = start; i < items.length; i++) {
        cur.add(items[i]);
        go(i + 1, cur);
        cur.removeLast();
      }
    }

    go(0, []);
    return result;
  }

  TeamSuggestion _evaluate(
      List<StudentProfile> members, String area, List<StudentProfile> pool) {
    final required = areaRequirements[area] ?? areaRequirements['Other']!;
    final n = members.length;

    // ----- Skill coverage (40) -----
    final allSkills = members.expand((m) => m.skills).toList();
    final covered = required.where((g) => hasGroup(allSkills, g)).toList();
    final missing = required.where((g) => !covered.contains(g)).toList();
    final coverageScore = (covered.length / required.length * 40).round();

    // ----- Role diversity (20) -----
    final roles = members
        .map((m) => m.preferredRole)
        .where((r) => r.isNotEmpty)
        .toSet();
    final roleScore = (roles.length / n * 20).round();

    // ----- Interests (20) -----
    final inArea = members.where((m) => m.fypArea == area).length;
    final counts = <String, int>{};
    for (final m in members) {
      for (final i in m.interests.map((e) => e.toLowerCase()).toSet()) {
        counts[i] = (counts[i] ?? 0) + 1;
      }
    }
    final sharedInterests = counts.values.where((c) => c >= 2).length;
    final interestScore =
    (inArea / n * 10 + min(sharedInterests, 3) / 3 * 10).round();

    // ----- Availability (10) -----
    final idx =
    members.map((m) => availabilityOptions.indexOf(m.availability)).toList();
    int availabilityScore;
    if (idx.contains(-1)) {
      availabilityScore = 5;
    } else {
      final spread = idx.reduce(max) - idx.reduce(min);
      availabilityScore = spread == 0 ? 10 : (spread == 1 ? 6 : 2);
    }

    // ----- Experience (10) -----
    final withExp = members
        .where((m) => m.experiences.any((e) => e.type != 'Academic Project'))
        .length;
    final experienceScore = (withExp / n * 10).round();

    // ----- Har member ka hissa -----
    final contributions = <String, List<String>>{};
    final uniqueGroups = <String, List<String>>{};
    for (final m in members) {
      final mine = required.where((g) => hasGroup(m.skills, g)).toList();
      final others = members
          .where((o) => o.uid != m.uid)
          .expand((o) => o.skills)
          .toList();
      contributions[m.uid] = mine;
      uniqueGroups[m.uid] = mine.where((g) => !hasGroup(others, g)).toList();
    }

    // ----- Missing groups ke liye mumkin students -----
    final inTeam = members.map((m) => m.uid).toSet();
    final fillers = <String, List<String>>{};
    for (final g in missing) {
      fillers[g] = pool
          .where((p) => !inTeam.contains(p.uid) && hasGroup(p.skills, g))
          .take(2)
          .map((p) => p.name)
          .toList();
    }

    // ----- Reasons -----
    final reasons = <String>[
      'Covers ${covered.length} of ${required.length} skill areas needed for $area',
    ];
    if (roles.length == n) {
      reasons.add('Every member prefers a different role');
    }
    if (sharedInterests > 0) {
      reasons.add('Team shares $sharedInterests common interest${sharedInterests > 1 ? 's' : ''}');
    }
    if (inArea == n) {
      reasons.add('Everyone wants an FYP in $area');
    }
    if (availabilityScore == 10) {
      reasons.add('All members have the same availability');
    }
    if (withExp > 0) {
      reasons.add(
          '$withExp of $n members have internship/professional experience');
    }

    final total = coverageScore +
        roleScore +
        interestScore +
        availabilityScore +
        experienceScore;

    return TeamSuggestion(
      members: members,
      score: total.clamp(0, 100),
      coverageScore: coverageScore,
      roleScore: roleScore,
      interestScore: interestScore.clamp(0, 20),
      availabilityScore: availabilityScore,
      experienceScore: experienceScore,
      requiredGroups: required,
      coveredGroups: covered,
      missingGroups: missing,
      contributions: contributions,
      uniqueGroups: uniqueGroups,
      fillers: fillers,
      reasons: reasons,
    );
  }
}