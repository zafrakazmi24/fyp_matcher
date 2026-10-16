import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_profile.dart';

class TeamMemberInfo {
  final String uid;
  final String name;
  final String cms;
  final List<String> skills;
  final List<String> interests;

  const TeamMemberInfo({
    required this.uid,
    required this.name,
    required this.cms,
    required this.skills,
    required this.interests,
  });

  factory TeamMemberInfo.fromProfile(StudentProfile p) => TeamMemberInfo(
    uid: p.uid,
    name: p.name,
    cms: p.cms,
    skills: p.skills,
    interests: p.interests,
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'cms': cms,
    'skills': skills,
    'interests': interests,
  };

  factory TeamMemberInfo.fromMap(Map<String, dynamic> m) => TeamMemberInfo(
    uid: m['uid'] ?? '',
    name: m['name'] ?? '',
    cms: m['cms'] ?? '',
    skills: List<String>.from(m['skills'] ?? []),
    interests: List<String>.from(m['interests'] ?? []),
  );
}

class SupervisionRequest {
  final String id;
  final String studentUid; // team leader (jis ne request bheji)
  final String studentName;
  final List<String> memberUids;
  final List<TeamMemberInfo> members;
  final String supervisorUid;
  final String supervisorName;
  final String projectTitle;
  final String area;
  final String message;
  final int score;
  final String status; // pending / accepted / rejected / cancelled
  final String note; // supervisor ka jawab
  final DateTime? createdAt;

  SupervisionRequest({
    required this.id,
    required this.studentUid,
    required this.studentName,
    required this.memberUids,
    required this.members,
    required this.supervisorUid,
    required this.supervisorName,
    required this.projectTitle,
    required this.area,
    required this.message,
    required this.score,
    required this.status,
    required this.note,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';

  factory SupervisionRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return SupervisionRequest(
      id: d.id,
      studentUid: m['studentUid'] ?? '',
      studentName: m['studentName'] ?? '',
      memberUids: List<String>.from(m['memberUids'] ?? []),
      members: (m['members'] as List? ?? [])
          .map((e) => TeamMemberInfo.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      supervisorUid: m['supervisorUid'] ?? '',
      supervisorName: m['supervisorName'] ?? '',
      projectTitle: m['projectTitle'] ?? '',
      area: m['area'] ?? '',
      message: m['message'] ?? '',
      score: (m['score'] ?? 0) as int,
      status: m['status'] ?? 'pending',
      note: m['note'] ?? '',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}