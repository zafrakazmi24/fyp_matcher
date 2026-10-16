import 'student_profile.dart';

class TeammateMatch {
  final StudentProfile student;
  final int score; // 0-100
  final int interestScore; // out of 30
  final int skillScore; // out of 35
  final int experienceScore; // out of 15
  final int availabilityScore; // out of 10
  final int roleScore; // out of 10
  final List<String> reasons;
  final List<String> sharedSkills;
  final List<String> complementarySkills;
  final List<String> sharedInterests;

  TeammateMatch({
    required this.student,
    required this.score,
    required this.interestScore,
    required this.skillScore,
    required this.experienceScore,
    required this.availabilityScore,
    required this.roleScore,
    required this.reasons,
    required this.sharedSkills,
    required this.complementarySkills,
    required this.sharedInterests,
  });

  String get label {
    if (score >= 75) return 'Excellent match';
    if (score >= 55) return 'Good match';
    if (score >= 35) return 'Fair match';
    return 'Low match';
  }
}