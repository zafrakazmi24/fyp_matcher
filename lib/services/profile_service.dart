import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_profile.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('student_profiles');

  // Profile live stream. Agar abhi profile nahi bana to empty profile deta hai.
  Stream<StudentProfile> watch(String uid) {
    return _col.doc(uid).snapshots().asyncMap((snap) async {
      if (snap.exists) return StudentProfile.fromMap(snap.data()!);
      final u = await _db.collection('users').doc(uid).get();
      return StudentProfile.empty(
        uid,
        u.data()?['name'] ?? '',
        u.data()?['cmsNumber'] ?? '',
      );
    });
  }

  Future<void> save(StudentProfile p) =>
      _col.doc(p.uid).set(p.toMap(), SetOptions(merge: true));
}