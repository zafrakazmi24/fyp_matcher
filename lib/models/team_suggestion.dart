import 'student_profile.dart';

class TeamSuggestion {
  final List<StudentProfile> members; // members[0] = aap
  final int score;
  final int coverageScore; // /40
  final int roleScore; // /20
  final int interestScore; // /20
  final int availabilityScore; // /10
  final int experienceScore; // /10
  final List<String> requiredGroups;
  final List<String> coveredGroups;
  final List<String> missingGroups;
  final Map<String, List<String>> contributions; // uid -> groups
  final Map<String, List<String>> uniqueGroups; // uid -> sirf isi ke paas
  final Map<String, List<String>> fillers; // missing group -> students ke naam
  final List<String> reasons;

  TeamSuggestion({
    required this.members,
    required this.score,
    required this.coverageScore,
    required this.roleScore,
    required this.interestScore,
    required this.availabilityScore,
    required this.experienceScore,
    required this.requiredGroups,
    required this.coveredGroups,
    required this.missingGroups,
    required this.contributions,
    required this.uniqueGroups,
    required this.fillers,
    required this.reasons,
  });

  String get label {
    if (score >= 75) return 'Excellent team';
    if (score >= 55) return 'Strong team';
    if (score >= 35) return 'Decent team';
    return 'Needs improvement';
  }
}