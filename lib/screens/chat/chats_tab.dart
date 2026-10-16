import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/supervision_request.dart';
import '../../services/chat_service.dart';
import '../../services/request_service.dart';
import 'chat_screen.dart';

const _bg = Color(0xFFF6F9FE);
const _muted = Color(0xFF7A88A5);

class ChatsTab extends StatefulWidget {
  final bool isSupervisor;
  const ChatsTab({super.key, required this.isSupervisor});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  late final Stream<List<SupervisionRequest>> _stream;
  final _chat = ChatService();

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _stream = widget.isSupervisor
        ? RequestService().watchForSupervisor(uid)
        : RequestService().watchForStudent(uid);
  }

  String _title(SupervisionRequest r) =>
      widget.isSupervisor ? '${r.studentName}\'s team' : r.supervisorName;

  String _subtitle(SupervisionRequest r) => widget.isSupervisor
      ? r.members.map((m) => m.name).join(', ')
      : 'Your supervisor';

  Widget _header() => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7468EE), AppColors.primaryDark],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Messages',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(
                widget.isSupervisor
                    ? 'Chat with the teams you supervise'
                    : 'Private chat with your supervisor',
                style: TextStyle(color: Colors.white.withOpacity(0.8))),
          ],
        ),
      ),
    ),
  );

  Widget _tile(SupervisionRequest r) {
    final title = _title(r);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
              request: r, title: title, subtitle: _subtitle(r)),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _chat.watchChat(r.id),
          builder: (context, snap) {
            final d = snap.data?.data();
            final last = d?['lastMessage'] as String?;
            final at = (d?['lastAt'] as Timestamp?)?.toDate();
            final mineLast =
                d?['lastSenderUid'] == FirebaseAuth.instance.currentUser!.uid;

            return Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    title.isEmpty ? '?' : title[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: AppColors.navy)),
                      const SizedBox(height: 3),
                      Text(
                        last == null
                            ? 'No messages yet. Say hello!'
                            : '${mineLast ? 'You: ' : ''}$last',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (at != null)
                  Text(DateFormat('d MMM').format(at.toLocal()),
                      style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: Column(
        children: [
          _header(),
          Expanded(
            child: StreamBuilder<List<SupervisionRequest>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(
                      child:
                      CircularProgressIndicator(color: AppColors.primary));
                }
                final chats = snap.data!.where((r) => r.isAccepted).toList();
                if (chats.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline,
                                size: 52, color: AppColors.primary),
                          ),
                          const SizedBox(height: 18),
                          const Text('No chats yet',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text(
                            widget.isSupervisor
                                ? 'Chat opens after you accept a team\'s request.'
                                : 'Chat opens after a supervisor accepts your request.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  children: chats.map(_tile).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}