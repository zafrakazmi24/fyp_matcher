import 'package:cloud_firestore/cloud_firestore.dart';

class SupervisorProfile {
  final String uid;
  final String name;
  final String designation;
  final String department;
  final String about;
  final List<String> expertise; // technical expertise
  final List<String> researchInterests;
  final List<String> preferredAreas; // preferred FYP areas
  final String availability;
  final int maxTeams;

  SupervisorProfile({
    required this.uid,
    required this.name,
    this.designation = '',
    this.department = '',
    this.about = '',
    this.expertise = const [],
    this.researchInterests = const [],
    this.preferredAreas = const [],
    this.availability = '',
    this.maxTeams = 3,
  });

  factory SupervisorProfile.empty(
      String uid, String name, String designation, String department) =>
      SupervisorProfile(
        uid: uid,
        name: name,
        designation: designation,
        department: department,
      );

  int get completion {
    int done = 0;
    if (about.trim().isNotEmpty) done++;
    if (expertise.isNotEmpty) done++;
    if (researchInterests.isNotEmpty) done++;
    if (preferredAreas.isNotEmpty) done++;
    if (availability.isNotEmpty) done++;
    return (done / 5 * 100).round();
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'designation': designation,
    'department': department,
    'about': about,
    'expertise': expertise,
    'researchInterests': researchInterests,
    'preferredAreas': preferredAreas,
    'availability': availability,
    'maxTeams': maxTeams,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory SupervisorProfile.fromMap(Map<String, dynamic> m) =>
      SupervisorProfile(
        uid: m['uid'] ?? '',
        name: m['name'] ?? '',
        designation: m['designation'] ?? '',
        department: m['department'] ?? '',
        about: m['about'] ?? '',
        expertise: List<String>.from(m['expertise'] ?? []),
        researchInterests: List<String>.from(m['researchInterests'] ?? []),
        preferredAreas: List<String>.from(m['preferredAreas'] ?? []),
        availability: m['availability'] ?? '',
        maxTeams: (m['maxTeams'] ?? 3) as int,
      );
}