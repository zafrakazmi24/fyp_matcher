import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supervisor_profile.dart';

class SupervisorService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('supervisor_profiles');

  // Profile live stream. Agar abhi profile nahi bana to signup ka data deta hai.
  Stream<SupervisorProfile> watch(String uid) {
    return _col.doc(uid).snapshots().asyncMap((snap) async {
      if (snap.exists) return SupervisorProfile.fromMap(snap.data()!);
      final u = await _db.collection('users').doc(uid).get();
      return SupervisorProfile.empty(
        uid,
        u.data()?['name'] ?? '',
        u.data()?['designation'] ?? '',
        u.data()?['department'] ?? '',
      );
    });
  }

  Future<void> save(SupervisorProfile p) =>
      _col.doc(p.uid).set(p.toMap(), SetOptions(merge: true));
}