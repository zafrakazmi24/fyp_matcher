import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_profile.dart';
import '../models/supervision_request.dart';
import '../models/supervisor_profile.dart';

class RequestService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('supervision_requests');

  List<SupervisionRequest> _parse(QuerySnapshot<Map<String, dynamic>> s) {
    final list = s.docs.map(SupervisionRequest.fromDoc).toList();
    list.sort((a, b) {
      final x = a.createdAt ?? DateTime.now();
      final y = b.createdAt ?? DateTime.now();
      return y.compareTo(x);
    });
    return list;
  }

  /// Team ke kisi bhi member ko apni team ki requests dikhti hain
  Stream<List<SupervisionRequest>> watchForStudent(String uid) =>
      _col.where('memberUids', arrayContains: uid).snapshots().map(_parse);

  Stream<List<SupervisionRequest>> watchForSupervisor(String uid) =>
      _col.where('supervisorUid', isEqualTo: uid).snapshots().map(_parse);

  /// Success par null, warna error message
  Future<String?> send({
    required StudentProfile leader,
    required List<StudentProfile> team,
    required SupervisorProfile sup,
    required String projectTitle,
    required String area,
    required String message,
    required int score,
  }) async {
    try {
      // 1) Team ka supervisor pehle se to nahi
      final mine =
      await _col.where('memberUids', arrayContains: leader.uid).get();
      if (mine.docs.any((d) => d.data()['status'] == 'accepted')) {
        return 'Your team already has a supervisor.';
      }

      // 2) Isi supervisor ko pehle se request to nahi
      final id = '${leader.uid}_${sup.uid}';
      final existing = await _col.doc(id).get();
      if (existing.exists) {
        final st = existing.data()!['status'];
        if (st == 'pending') return 'Your request is already pending.';
        if (st == 'accepted') return 'This supervisor already accepted you.';
      }

      // 3) Supervisor ke slots
      final acc = await _col
          .where('supervisorUid', isEqualTo: sup.uid)
          .where('status', isEqualTo: 'accepted')
          .get();
      if (acc.docs.length >= sup.maxTeams) {
        return 'This supervisor has no free slots left.';
      }

      await _col.doc(id).set({
        'studentUid': leader.uid,
        'studentName': leader.name,
        'memberUids': team.map((p) => p.uid).toList(),
        'members':
        team.map((p) => TeamMemberInfo.fromProfile(p).toMap()).toList(),
        'supervisorUid': sup.uid,
        'supervisorName': sup.name,
        'projectTitle': projectTitle,
        'area': area,
        'message': message,
        'score': score,
        'status': 'pending',
        'note': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Could not send request: $e';
    }
  }

  Future<String?> cancel(SupervisionRequest r) async {
    try {
      await _col.doc(r.id).delete();
      return null;
    } catch (e) {
      return 'Could not cancel: $e';
    }
  }

  Future<String?> respond(
      SupervisionRequest r, {
        required bool accept,
        String note = '',
      }) async {
    try {
      if (!accept) {
        await _col.doc(r.id).update({
          'status': 'rejected',
          'note': note,
          'respondedAt': FieldValue.serverTimestamp(),
        });
        return null;
      }

      // Slots check
      final sup = await _db
          .collection('supervisor_profiles')
          .doc(r.supervisorUid)
          .get();
      final max = (sup.data()?['maxTeams'] ?? 3) as int;
      final acc = await _col
          .where('supervisorUid', isEqualTo: r.supervisorUid)
          .where('status', isEqualTo: 'accepted')
          .get();
      if (acc.docs.length >= max) {
        return 'You already have $max accepted teams. Increase "Maximum Teams" in your profile to accept more.';
      }

      // Team ka supervisor pehle se to nahi
      final mine =
      await _col.where('memberUids', arrayContains: r.studentUid).get();
      if (mine.docs.any((d) => d.data()['status'] == 'accepted')) {
        return 'This team already has a supervisor.';
      }

      final batch = _db.batch();
      batch.update(_col.doc(r.id), {
        'status': 'accepted',
        'note': note,
        'respondedAt': FieldValue.serverTimestamp(),
      });
      // Isi team ki baqi pending requests cancel
      for (final d in mine.docs) {
        final m = d.data();
        if (d.id != r.id &&
            m['studentUid'] == r.studentUid &&
            m['status'] == 'pending') {
          batch.update(d.reference, {
            'status': 'cancelled',
            'note': 'The team got another supervisor.',
          });
        }
      }
      await batch.commit();
      return null;
    } catch (e) {
      return 'Could not update request: $e';
    }
  }
}