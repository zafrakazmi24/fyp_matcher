import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/supervision_request.dart';
import '../../services/request_service.dart';
import '../chat/chat_screen.dart';

const _bg = Color(0xFFF6F9FE);
const _muted = Color(0xFF7A88A5);
const _green = Color(0xFF22B573);
const _orange = Color(0xFFF5A623);
const _red = Color(0xFFE5484D);

class StudentRequestsTab extends StatefulWidget {
  const StudentRequestsTab({super.key});

  @override
  State<StudentRequestsTab> createState() => _StudentRequestsTabState();
}

class _StudentRequestsTabState extends State<StudentRequestsTab> {
  late final Stream<List<SupervisionRequest>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = RequestService()
        .watchForStudent(FirebaseAuth.instance.currentUser!.uid);
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted':
        return _green;
      case 'pending':
        return _orange;
      default:
        return _red;
    }
  }

  String _statusText(String s) {
    switch (s) {
      case 'accepted':
        return 'Accepted';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Declined';
      default:
        return 'Cancelled';
    }
  }

  Future<void> _cancel(SupervisionRequest r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cancel request?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Your request to ${r.supervisorName} will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancel request')),
        ],
      ),
    );
    if (ok != true) return;
    final err = await RequestService().cancel(r);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

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
            const Text('My Requests',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text('Track your supervisor requests',
                style: TextStyle(color: Colors.white.withOpacity(0.8))),
          ],
        ),
      ),
    ),
  );

  Widget _card(SupervisionRequest r) {
    final c = _statusColor(r.status);
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(r.supervisorName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppColors.navy)),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_statusText(r.status),
                    style: TextStyle(
                        color: c,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.projectTitle.isEmpty ? 'Untitled project' : r.projectTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text('${r.area} • ${r.score}% match',
              style: const TextStyle(color: _muted, fontSize: 12)),
          const SizedBox(height: 10),
          Text('Team: ${r.members.map((m) => m.name).join(', ')}',
              style: const TextStyle(fontSize: 13)),
          if (r.createdAt != null) ...[
            const SizedBox(height: 4),
            Text('Sent ${DateFormat('d MMM, h:mm a').format(r.createdAt!)}',
                style: const TextStyle(color: _muted, fontSize: 12)),
          ],
          if (r.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Your message: ${r.message}',
                style: const TextStyle(fontSize: 13)),
          ],
          if (r.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Supervisor: ${r.note}',
                  style: const TextStyle(fontSize: 13)),
            ),
          ],
          if (r.isAccepted) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Open Chat'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    request: r,
                    title: r.supervisorName,
                    subtitle: 'Your supervisor',
                  ),
                ),
              ),
            ),
          ],
          if (r.isPending) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _cancel(r),
                icon: const Icon(Icons.close, color: _red, size: 18),
                label: const Text('Cancel request',
                    style: TextStyle(color: _red)),
              ),
            ),
          ],
        ],
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
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }
                final list = snap.data!;
                if (list.isEmpty) {
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
                            child: const Icon(Icons.assignment_outlined,
                                size: 52, color: AppColors.primary),
                          ),
                          const SizedBox(height: 18),
                          const Text('No requests yet',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text(
                            'Open Find Supervisor from Home and send a request to your best match.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  children: list.map(_card).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}