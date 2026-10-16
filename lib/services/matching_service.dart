import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/student_profile.dart';
import '../models/teammate_match.dart';

class MatchingService {
  final _db = FirebaseFirestore.instance;

  /// Dusre students ko fetch karke score ke hisaab se sort karta hai.
  Future<List<TeammateMatch>> findMatches(StudentProfile me) async {
    final snap = await _db.collection('student_profiles').get();

    final matches = snap.docs
        .map((d) => StudentProfile.fromMap(d.data()))
        .where((p) => p.uid != me.uid && p.skills.isNotEmpty)
        .map((p) => score(me, p))
        .toList();

    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }

  // ---------------- SCORING ----------------
  static TeammateMatch score(StudentProfile me, StudentProfile other) {
    final reasons = <String>[];

    // ----- Skills (35) -----
    final mySkills = me.skills.map((s) => s.toLowerCase()).toSet();
    final theirSkills = {for (final s in other.skills) s.toLowerCase(): s};

    final sharedSkills = theirSkills.entries
        .where((e) => mySkills.contains(e.key))
        .map((e) => e.value)
        .toList();
    final complementary = theirSkills.entries
        .where((e) => !mySkills.contains(e.key))
        .map((e) => e.value)
        .toList();

    double common = 0;
    if (mySkills.isNotEmpty && theirSkills.isNotEmpty) {
      common =
          sharedSkills.length / min(mySkills.length, theirSkills.length) * 10;
    }
    final comp = min(complementary.length, 5) / 5 * 25;
    final skillScore = (common + comp).round();

    // ----- Interests (30) -----
    final myInterests = me.interests.map((s) => s.toLowerCase()).toSet();
    final theirInterests = {for (final s in other.interests) s.toLowerCase(): s};
    final sharedInterests = theirInterests.entries
        .where((e) => myInterests.contains(e.key))
        .map((e) => e.value)
        .toList();

    final sameArea = me.fypArea.isNotEmpty && me.fypArea == other.fypArea;
    double interest = sameArea ? 12 : 0;
    if (myInterests.isNotEmpty && theirInterests.isNotEmpty) {
      interest += sharedInterests.length /
          min(myInterests.length, theirInterests.length) *
          18;
    }
    final interestScore = interest.round().clamp(0, 30);

    // ----- Experience (15) -----
    double points = 0;
    final strong = <Experience>[];
    for (final e in other.experiences) {
      if (e.type == 'Academic Project') {
        points += 0.5;
      } else {
        points += 1;
        strong.add(e);
      }
    }
    final experienceScore = (min(points, 3) / 3 * 15).round();

    // ----- Availability (10) -----
    int availabilityScore = 0;
    final a1 = availabilityOptions.indexOf(me.availability);
    final a2 = availabilityOptions.indexOf(other.availability);
    if (a1 != -1 && a2 != -1) {
      final diff = (a1 - a2).abs();
      availabilityScore = diff == 0 ? 10 : (diff == 1 ? 6 : 2);
    }

    // ----- Role (10) -----
    int roleScore = 0;
    if (me.preferredRole.isNotEmpty && other.preferredRole.isNotEmpty) {
      roleScore = me.preferredRole == other.preferredRole ? 4 : 10;
    }

    // ----- Reasons (simple, insaan ko samajh aane wali) -----
    if (sharedInterests.isNotEmpty) {
      reasons.add('Shares your interest in ${sharedInterests.take(3).join(', ')}');
    }
    if (sameArea) {
      reasons.add('Also wants to do an FYP in ${other.fypArea}');
    }
    if (complementary.isNotEmpty) {
      reasons.add(
          'Brings skills you do not have: ${complementary.take(4).join(', ')}');
    }
    if (sharedSkills.isNotEmpty) {
      reasons.add('Common ground in ${sharedSkills.take(3).join(', ')}');
    }
    if (strong.isNotEmpty) {
      final e = strong.first;
      final more = strong.length > 1 ? ' (+${strong.length - 1} more)' : '';
      reasons.add(
          'Has ${e.type.toLowerCase()} experience: ${e.title}$more');
    }
    if (availabilityScore == 10) {
      reasons.add('Same availability as you (${other.availability})');
    }
    if (roleScore == 10) {
      reasons.add(
          'Prefers ${other.preferredRole}, which complements your ${me.preferredRole} role');
    } else if (roleScore == 4) {
      reasons.add('Prefers the same role as you (${other.preferredRole})');
    }
    if (reasons.isEmpty) {
      reasons.add('Not much in common yet. Their profile may be incomplete.');
    }

    final total = skillScore +
        interestScore +
        experienceScore +
        availabilityScore +
        roleScore;

    return TeammateMatch(
      student: other,
      score: total.clamp(0, 100),
      interestScore: interestScore,
      skillScore: skillScore.clamp(0, 35),
      experienceScore: experienceScore,
      availabilityScore: availabilityScore,
      roleScore: roleScore,
      reasons: reasons,
      sharedSkills: sharedSkills,
      complementarySkills: complementary,
      sharedInterests: sharedInterests,
    );
  }
}