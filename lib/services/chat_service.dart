import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_message.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  static const maxFileBytes = 10 * 1024 * 1024; // 10 MB

  // chatId = accepted supervision request ka id
  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _db.collection('chats').doc(chatId).collection('messages');

  Stream<List<ChatMessage>> watch(String chatId) => _messages(chatId)
      .orderBy('createdAt', descending: true)
      .limit(300)
      .snapshots()
      .map((s) => s.docs.map(ChatMessage.fromDoc).toList());

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchChat(String chatId) =>
      _db.collection('chats').doc(chatId).snapshots();

  Future<void> _touch(String chatId, String preview, String senderUid) =>
      _db.collection('chats').doc(chatId).set({
        'lastMessage': preview,
        'lastSenderUid': senderUid,
        'lastAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  /// Success par null, warna error message
  Future<String?> sendText({
    required String chatId,
    required String senderUid,
    required String senderName,
    required String text,
  }) async {
    try {
      await _messages(chatId).add({
        'senderUid': senderUid,
        'senderName': senderName,
        'type': 'text',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _touch(chatId, text, senderUid);
      return null;
    } catch (e) {
      return 'Could not send message: $e';
    }
  }

  Future<String?> sendFile({
    required String chatId,
    required String senderUid,
    required String senderName,
    required PlatformFile file,
  }) async {
    try {
      // Pehle size dekh lein (agar picker ne bata diya ho)
      final reported = file.lengthSync();
      if (reported != null && reported > maxFileBytes) {
        return 'File is too large. Maximum size is 10 MB.';
      }

      final bytes = await file.readAsBytes();
      if (bytes.length > maxFileBytes) {
        return 'File is too large. Maximum size is 10 MB.';
      }

      final safe = file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final ref = _storage
          .ref('chats/$chatId/${DateTime.now().millisecondsSinceEpoch}_$safe');
      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      await _messages(chatId).add({
        'senderUid': senderUid,
        'senderName': senderName,
        'type': 'file',
        'text': '',
        'fileName': file.name,
        'fileUrl': url,
        'fileSize': bytes.length,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _touch(chatId, 'Document: ${file.name}', senderUid);
      return null;
    } catch (e) {
      return 'Could not upload file: $e';
    }
  }
}