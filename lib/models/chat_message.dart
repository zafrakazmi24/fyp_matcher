import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderUid;
  final String senderName;
  final String type; // text / file
  final String text;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.type,
    required this.text,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.createdAt,
  });

  bool get isFile => type == 'file';

  factory ChatMessage.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return ChatMessage(
      id: d.id,
      senderUid: m['senderUid'] ?? '',
      senderName: m['senderName'] ?? '',
      type: m['type'] ?? 'text',
      text: m['text'] ?? '',
      fileName: m['fileName'] ?? '',
      fileUrl: m['fileUrl'] ?? '',
      fileSize: (m['fileSize'] ?? 0) as int,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}