import '../core/fyp_ideas.dart';
import '../core/skill_groups.dart';
import '../models/student_profile.dart';

class IdeaMatch {
  final FypIdea idea;
  final int score;
  final int skillScore; // /50
  final int interestScore; // /30
  final int areaScore; // /20
  final List<String> haveSkills;
  final List<String> partialSkills; // same group ki skill hai
  final List<String> needSkills;
  final List<String> matchedInterests;
  final List<String> reasons;

  IdeaMatch({
    required this.idea,
    required this.score,
    required this.skillScore,
    required this.interestScore,
    required this.areaScore,
    required this.haveSkills,
    required this.partialSkills,
    required this.needSkills,
    required this.matchedInterests,
    required this.reasons,
  });

  String get label {
    if (score >= 75) return 'Excellent fit';
    if (score >= 55) return 'Good fit';
    if (score >= 35) return 'Possible fit';
    return 'Stretch idea';
  }
}

class IdeaService {
  /// [domain] null ho to "Any area". [exclude] mein pehle dikhaye gaye ideas.
  static List<IdeaMatch> recommend(
      StudentProfile p, {
        String? domain,
        Set<String> exclude = const {},
        int count = 5,
      }) {
    final mine =
    p.skills.map((s) => canonicalSkill(s).toLowerCase()).toSet();
    final myGroups = mine.map(groupOfSkill).whereType<String>().toSet();
    final myInterests = p.interests.map((e) => e.toLowerCase()).toSet();
    final hasExp = p.experiences.any((e) => e.type != 'Academic Project');

    final scored = <IdeaMatch>[];
    for (final idea in fypIdeas) {
      if (exclude.contains(idea.id)) continue;

      // ----- Skills (50) -----
      final have = <String>[];
      final partial = <String>[];
      final need = <String>[];
      double points = 0;
      for (final s in idea.skills) {
        final l = s.toLowerCase();
        if (mine.contains(l)) {
          have.add(s);
          points += 1;
        } else {
          final g = groupOfSkill(s);
          if (g != null && myGroups.contains(g)) {
            partial.add(s);
            points += 0.4;
          } else {
            need.add(s);
          }
        }
      }
      final skillScore = (points / idea.skills.length * 50).round();

      // ----- Interests (30) -----
      final matched = idea.interests
          .where((i) => myInterests.contains(i.toLowerCase()))
          .toList();
      final denom = idea.interests.length < 2 ? idea.interests.length : 2;
      final interestScore =
      (((matched.length > 2 ? 2 : matched.length) / denom) * 30).round();

      // ----- Domain (20) -----
      final areaScore = (domain != null && idea.area == domain) ? 20 : 0;

      var total = skillScore + interestScore + areaScore;

      // Bohot mushkil idea, kam skills aur koi experience nahi
      if (idea.difficulty == 'Advanced' && mine.length < 4 && !hasExp) {
        total -= 6;
      }

      // ----- Reasons -----
      final reasons = <String>[];
      if (matched.isNotEmpty) {
        reasons.add('Matches your interest in ${matched.join(', ')}');
      }
      if (areaScore > 0) {
        reasons.add('Fits your chosen FYP area: ${idea.area}');
      }
      if (have.isNotEmpty) {
        reasons.add('You already know ${have.join(', ')}');
      }
      if (partial.isNotEmpty) {
        reasons.add(
            'Your related skills will help you pick up ${partial.join(', ')} quickly');
      }
      if (need.isNotEmpty) {
        reasons.add('You will need to learn ${need.join(', ')}');
      }
      if (idea.difficulty == 'Beginner') {
        reasons.add('Beginner-friendly: realistic to finish in one FYP');
      }
      if (reasons.isEmpty) {
        reasons.add('A popular real-world project in ${idea.area}');
      }

      scored.add(IdeaMatch(
        idea: idea,
        score: total.clamp(0, 100),
        skillScore: skillScore,
        interestScore: interestScore,
        areaScore: areaScore,
        haveSkills: have,
        partialSkills: partial,
        needSkills: need,
        matchedInterests: matched,
        reasons: reasons,
      ));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    // Ek area se zyada ideas na aayein (chune hue area ke 5 tak)
    final result = <IdeaMatch>[];
    final perArea = <String, int>{};
    for (final m in scored) {
      final cap = m.idea.area == domain ? count : 3;
      final used = perArea[m.idea.area] ?? 0;
      if (used >= cap) continue;
      perArea[m.idea.area] = used + 1;
      result.add(m);
      if (result.length == count) break;
    }
    return result;
  }
}