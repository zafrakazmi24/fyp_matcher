import 'package:cloud_firestore/cloud_firestore.dart';

class Experience {
  final String type; // Internship / Professional / Academic Project
  final String title;
  final String organization;
  final String duration;

  Experience({
    required this.type,
    required this.title,
    required this.organization,
    required this.duration,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'title': title,
    'organization': organization,
    'duration': duration,
  };

  factory Experience.fromMap(Map<String, dynamic> m) => Experience(
    type: m['type'] ?? 'Internship',
    title: m['title'] ?? '',
    organization: m['organization'] ?? '',
    duration: m['duration'] ?? '',
  );
}

class StudentProfile {
  final String uid;
  final String name;
  final String cms;
  final String about;
  final String fypArea;
  final String preferredRole;
  final String availability;
  final List<String> skills;
  final List<String> interests;
  final List<Experience> experiences;

  StudentProfile({
    required this.uid,
    required this.name,
    required this.cms,
    this.about = '',
    this.fypArea = '',
    this.preferredRole = '',
    this.availability = '',
    this.skills = const [],
    this.interests = const [],
    this.experiences = const [],
  });

  factory StudentProfile.empty(String uid, String name, String cms) =>
      StudentProfile(uid: uid, name: name, cms: cms);

  int get completion {
    int done = 0;
    if (about.trim().isNotEmpty) done++;
    if (skills.isNotEmpty) done++;
    if (interests.isNotEmpty) done++;
    if (fypArea.isNotEmpty) done++;
    if (preferredRole.isNotEmpty) done++;
    if (availability.isNotEmpty) done++;
    if (experiences.isNotEmpty) done++;
    return (done / 7 * 100).round();
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'cms': cms,
    'about': about,
    'fypArea': fypArea,
    'preferredRole': preferredRole,
    'availability': availability,
    'skills': skills,
    'interests': interests,
    'experiences': experiences.map((e) => e.toMap()).toList(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory StudentProfile.fromMap(Map<String, dynamic> m) => StudentProfile(
    uid: m['uid'] ?? '',
    name: m['name'] ?? '',
    cms: m['cms'] ?? '',
    about: m['about'] ?? '',
    fypArea: m['fypArea'] ?? '',
    preferredRole: m['preferredRole'] ?? '',
    availability: m['availability'] ?? '',
    skills: List<String>.from(m['skills'] ?? []),
    interests: List<String>.from(m['interests'] ?? []),
    experiences: (m['experiences'] as List? ?? [])
        .map((e) => Experience.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
  );
}