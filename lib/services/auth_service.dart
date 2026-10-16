import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Success par null, warna error message return karta hai
  Future<String?> signUp({
    required String role,
    required String name,
    required String email,
    required String password,
    Map<String, dynamic> extra = const {},
  }) async {
    UserCredential? cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        ...extra,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e);
    } catch (e) {
      // Firestore write fail ho to adhoora account hata do
      await cred?.user?.delete();
      return 'Something went wrong: $e';
    }
  }

  Future<String?> login({
    required String role,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists || doc.data()!['role'] != role) {
        await _auth.signOut();
        return 'This account is not registered as a $role.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e);
    } catch (e) {
      return 'Something went wrong: $e';
    }
  }

  Future<void> logout() => _auth.signOut();

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}