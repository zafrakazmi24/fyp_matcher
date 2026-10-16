import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/supervision_request.dart';
import '../../services/request_service.dart';

const _bg = Color(0xFFF6F9FE);
const _muted = Color(0xFF7A88A5);
const _green = Color(0xFF22B573);
const _red = Color(0xFFE5484D);

class SupervisorRequestsTab extends StatefulWidget {
  const SupervisorRequestsTab({super.key});

  @override
  State<SupervisorRequestsTab> createState() => _SupervisorRequestsTabState();
}

class _SupervisorRequestsTabState extends State<SupervisorRequestsTab> {
  late final Stream<List<SupervisionRequest>> _stream;
  String _filter = 'pending'; // pending / accepted / closed
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _stream = RequestService()
        .watchForSupervisor(FirebaseAuth.instance.currentUser!.uid);
  }

  bool _inFilter(SupervisionRequest r) {
    if (_filter == 'pending') return r.status == 'pending';
    if (_filter == 'accepted') return r.status == 'accepted';
    return r.status == 'rejected' || r.status == 'cancelled';
  }

  Future<void> _respond(SupervisionRequest r, bool accept) async {
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(accept ? 'Accept this team?' : 'Decline this request?',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: note,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: _bg,
            hintText: accept
                ? 'Welcome note (optional)'
                : 'Reason for declining (optional)',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(accept ? 'Accept' : 'Decline',
                  style: TextStyle(color: accept ? _green : _red))),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busyId = r.id);
    final err = await RequestService()
        .respond(r, accept: accept, note: note.text.trim());
    if (!mounted) return;
    setState(() => _busyId = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ??
            (accept ? 'Team accepted' : 'Request declined'))));
  }

  Widget _chip(String text, {Color? color}) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: c)),
    );
  }

  Widget _header(List<SupervisionRequest> all) {
    int count(bool Function(SupervisionRequest) f) => all.where(f).length;
    final pending = count((r) => r.status == 'pending');
    final accepted = count((r) => r.status == 'accepted');
    final closed =
    count((r) => r.status == 'rejected' || r.status == 'cancelled');

    Widget tab(String key, String label, int n) {
      final sel = _filter == key;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _filter = key),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: sel ? Colors.white : Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$label ($n)',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: sel ? AppColors.primary : Colors.white)),
          ),
        ),
      );
    }

    return Container(
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
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Student Requests',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text('Review teams who want you as their supervisor',
                  style: TextStyle(color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 18),
              Row(
                children: [
                  tab('pending', 'Pending', pending),
                  const SizedBox(width: 8),
                  tab('accepted', 'Accepted', accepted),
                  const SizedBox(width: 8),
                  tab('closed', 'Closed', closed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(SupervisionRequest r) {
    final busy = _busyId == r.id;
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
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  r.studentName.isEmpty ? '?' : r.studentName[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.studentName}\'s team',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: AppColors.navy)),
                    Text(
                      '${r.members.length} member${r.members.length > 1 ? 's' : ''}'
                          '${r.createdAt == null ? '' : ' • ${DateFormat('d MMM, h:mm a').format(r.createdAt!)}'}',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _chip('${r.score}% match', color: _green),
            ],
          ),
          const SizedBox(height: 12),
          Text(r.projectTitle.isEmpty ? 'Untitled project' : r.projectTitle,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          _chip(r.area),
          if (r.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(r.message),
            ),
          ],
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: const Text('Team members',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.primary)),
              children: r.members
                  .map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${m.name}  •  CMS ${m.cms}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...m.skills.take(6).map((e) => _chip(e)),
                          ...m.interests
                              .take(3)
                              .map((e) => _chip(e, color: _green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
          if (r.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Your note: ${r.note}',
                  style: const TextStyle(color: _muted, fontSize: 13)),
            ),
          if (r.isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : () => _respond(r, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red, width: 1.5),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Decline',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: busy ? null : () => _respond(r, true),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: busy
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                        : const Text('Accept'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: StreamBuilder<List<SupervisionRequest>>(
        stream: _stream,
        builder: (context, snap) {
          final all = snap.data ?? [];
          final shown = all.where(_inFilter).toList();

          Widget body;
          if (snap.hasError) {
            body = Center(child: Text('${snap.error}'));
          } else if (!snap.hasData) {
            body = const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          } else if (shown.isEmpty) {
            body = Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _filter == 'pending'
                      ? 'No pending requests right now.'
                      : _filter == 'accepted'
                      ? 'You have not accepted any team yet.'
                      : 'Nothing here.',
                  style: const TextStyle(color: _muted),
                ),
              ),
            );
          } else {
            body = ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              children: shown.map(_card).toList(),
            );
          }

          return Column(
            children: [
              _header(all),
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}