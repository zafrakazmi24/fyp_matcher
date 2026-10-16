import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../core/skill_groups.dart';
import '../models/student_profile.dart';
import '../models/supervisor_profile.dart';
import 'nlp_service.dart';

class SupervisorMatch {
  final SupervisorProfile profile;
  final int score;
  final int expertiseScore; // /35
  final int interestScore; // /25
  final int areaScore; // /25
  final int availabilityScore; // /15
  final int slotsLeft;
  final List<String> matchedSkills;
  final List<String> relatedSkills;
  final List<String> matchedInterests;
  final List<String> reasons;

  SupervisorMatch({
    required this.profile,
    required this.score,
    required this.expertiseScore,
    required this.interestScore,
    required this.areaScore,
    required this.availabilityScore,
    required this.slotsLeft,
    required this.matchedSkills,
    required this.relatedSkills,
    required this.matchedInterests,
    required this.reasons,
  });

  bool get isFull => slotsLeft <= 0;

  String get label {
    if (score >= 75) return 'Excellent fit';
    if (score >= 55) return 'Good fit';
    if (score >= 35) return 'Possible fit';
    return 'Low fit';
  }
}

class SupervisorMatchingService {
  final _db = FirebaseFirestore.instance;

  Future<List<SupervisorMatch>> find({
    required List<StudentProfile> team, // team[0] = aap
    required String area,
    String projectText = '',
  }) async {
    final results = await Future.wait([
      _db.collection('supervisor_profiles').get(),
      _db
          .collection('supervision_requests')
          .where('status', isEqualTo: 'accepted')
          .get(),
    ]);

    final accepted = <String, int>{};
    for (final d in results[1].docs) {
      final u = (d.data()['supervisorUid'] ?? '') as String;
      accepted[u] = (accepted[u] ?? 0) + 1;
    }

    final sups = results[0]
        .docs
        .map((d) => SupervisorProfile.fromMap(d.data()))
        .where((s) => s.expertise.isNotEmpty)
        .toList();

    // ----- Team ka combined profile -----
    final teamSkills = <String, String>{}; // lower -> display
    for (final p in team) {
      for (final s in p.skills) {
        final c = canonicalSkill(s);
        teamSkills[c.toLowerCase()] = c;
      }
    }
    final rawInterests = team.expand((p) => p.interests).toList();
    final projNlp = NlpService.analyze(projectText);
    for (final s in projNlp.skills) {
      teamSkills[s.toLowerCase()] = s;
    }
    final teamInterests = _interestMap(rawInterests, projectText);

    final matches = sups
        .map((s) => _score(
      sup: s,
      area: area,
      teamSkills: teamSkills,
      teamInterests: teamInterests,
      teamAvailability: team.first.availability,
      slotsLeft: max(0, s.maxTeams - (accepted[s.uid] ?? 0)),
    ))
        .toList();

    matches.sort((a, b) {
      if (a.isFull != b.isFull) return a.isFull ? 1 : -1;
      return b.score.compareTo(a.score);
    });
    return matches;
  }

  static Map<String, String> _interestMap(List<String> raw, String extra) {
    final map = <String, String>{};
    for (final r in raw) {
      final t = r.trim();
      if (t.isNotEmpty) map[t.toLowerCase()] = t;
    }
    final nlp = NlpService.analyze('${raw.join('. ')}. $extra');
    for (final i in nlp.interests) {
      map[i.toLowerCase()] = i;
    }
    return map;
  }

  static SupervisorMatch _score({
    required SupervisorProfile sup,
    required String area,
    required Map<String, String> teamSkills,
    required Map<String, String> teamInterests,
    required String teamAvailability,
    required int slotsLeft,
  }) {
    // ----- Expertise (35) -----
    final supSkills = <String, String>{};
    for (final s in sup.expertise) {
      final c = canonicalSkill(s);
      supSkills[c.toLowerCase()] = c;
    }
    for (final s in NlpService.analyze(sup.about).skills) {
      supSkills[s.toLowerCase()] = s;
    }
    final supGroups =
    supSkills.keys.map(groupOfSkill).whereType<String>().toSet();

    final exact =
    teamSkills.keys.where((k) => supSkills.containsKey(k)).toList();
    final related = teamSkills.keys.where((k) {
      if (supSkills.containsKey(k)) return false;
      final g = groupOfSkill(k);
      return g != null && supGroups.contains(g);
    }).toList();

    int expertiseScore = 0;
    if (teamSkills.isNotEmpty) {
      final covered = exact.length + related.length * 0.4;
      final denom = min(teamSkills.length, 8);
      expertiseScore = (min(1.0, covered / denom) * 35).round();
    }

    // ----- Research interests (25) -----
    final supInterests = _interestMap(
        sup.researchInterests, sup.about);
    final matchedInterestKeys =
    teamInterests.keys.where((k) => supInterests.containsKey(k)).toList();
    int interestScore = 0;
    if (teamInterests.isNotEmpty) {
      final denom = max(1, min(3, teamInterests.length));
      interestScore =
          (min(1.0, matchedInterestKeys.length / denom) * 25).round();
    }

    // ----- FYP area (25) -----
    int areaScore;
    final inPreferred = sup.preferredAreas.contains(area);
    if (inPreferred) {
      areaScore = 25;
    } else {
      final req = areaRequirements[area] ?? areaRequirements['Other']!;
      final c = req.where((g) => hasGroup(sup.expertise, g)).length;
      areaScore = (c / req.length * 12).round();
    }

    // ----- Availability (15) -----
    final slotPts = slotsLeft == 0 ? 0 : (min(slotsLeft, 3) / 3 * 10).round();
    int levelPts = 2;
    final a1 = availabilityOptions.indexOf(teamAvailability);
    final a2 = availabilityOptions.indexOf(sup.availability);
    if (a1 != -1 && a2 != -1) {
      final d = (a1 - a2).abs();
      levelPts = d == 0 ? 5 : (d == 1 ? 3 : 1);
    }
    final availabilityScore = slotPts + levelPts;

    // ----- Reasons -----
    final reasons = <String>[];
    if (exact.isNotEmpty) {
      reasons.add(
          'Expert in ${exact.take(4).map((k) => teamSkills[k]).join(', ')}, which your team uses');
    }
    if (related.isNotEmpty) {
      reasons.add(
          'Has related expertise to guide ${related.take(3).map((k) => teamSkills[k]).join(', ')}');
    }
    if (matchedInterestKeys.isNotEmpty) {
      reasons.add(
          'Research interests overlap: ${matchedInterestKeys.take(3).map((k) => teamInterests[k]).join(', ')}');
    }
    if (inPreferred) reasons.add('Supervises $area projects');
    if (slotsLeft > 0) {
      reasons.add('$slotsLeft team slot${slotsLeft > 1 ? 's' : ''} available');
    } else {
      reasons.add('Already has the maximum number of teams');
    }
    if (levelPts == 5) reasons.add('Availability matches yours');
    if (reasons.length == 1 && slotsLeft > 0) {
      reasons.add('Few direct matches. Their profile may be incomplete.');
    }

    final total = expertiseScore + interestScore + areaScore + availabilityScore;

    return SupervisorMatch(
      profile: sup,
      score: total.clamp(0, 100),
      expertiseScore: expertiseScore,
      interestScore: interestScore,
      areaScore: areaScore,
      availabilityScore: availabilityScore,
      slotsLeft: slotsLeft,
      matchedSkills: exact.map((k) => teamSkills[k]!).toList(),
      relatedSkills: related.map((k) => teamSkills[k]!).toList(),
      matchedInterests:
      matchedInterestKeys.map((k) => teamInterests[k]!).toList(),
      reasons: reasons,
    );
  }
}