import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/chat_message.dart';
import '../../models/supervision_request.dart';
import '../../services/chat_service.dart';

const _bg = Color(0xFFF6F9FE);
const _muted = Color(0xFF7A88A5);

class ChatScreen extends StatefulWidget {
  final SupervisionRequest request;
  final String title;
  final String subtitle;

  const ChatScreen({
    super.key,
    required this.request,
    required this.title,
    required this.subtitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _service = ChatService();
  final _input = TextEditingController();
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  late final Stream<List<ChatMessage>> _stream;
  late final String _myName;

  bool _docsView = false;
  bool _uploading = false;
  String _uploadingName = '';

  String get _chatId => widget.request.id;

  @override
  void initState() {
    super.initState();
    _myName = _nameOf(_uid);
    _stream = _service.watch(_chatId);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String _nameOf(String uid) {
    final r = widget.request;
    if (uid == r.supervisorUid) return r.supervisorName;
    for (final m in r.members) {
      if (m.uid == uid) return m.name;
    }
    return r.studentName;
  }

  void _snack(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  Future<void> _sendText() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    final err = await _service.sendText(
      chatId: _chatId,
      senderUid: _uid,
      senderName: _myName,
      text: text,
    );
    if (err != null && mounted) _snack(err);
  }

  Future<void> _attach() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx',
        'txt', 'png', 'jpg', 'jpeg', 'zip'
      ],
    );
    if (file == null) return;

    setState(() {
      _uploading = true;
      _uploadingName = file.name;
    });
    final err = await _service.sendFile(
      chatId: _chatId,
      senderUid: _uid,
      senderName: _myName,
      file: file,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    if (err != null) _snack(err);
  }

  Future<void> _open(ChatMessage m) async {
    try {
      final ok = await launchUrl(Uri.parse(m.fileUrl),
          mode: LaunchMode.externalApplication);
      if (!ok && mounted) _snack('No app found to open this file.');
    } catch (_) {
      if (mounted) _snack('Could not open this file.');
    }
  }

  // ---------------- helpers ----------------
  String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image_outlined;
      case 'zip':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _time(DateTime? d) =>
      DateFormat('h:mm a').format((d ?? DateTime.now()).toLocal());

  String _dateTime(DateTime? d) =>
      DateFormat('d MMM, h:mm a').format((d ?? DateTime.now()).toLocal());

  // ---------------- header ----------------
  Widget _header() => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7468EE), AppColors.primaryDark],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 20, 18),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Text(
                widget.title.isEmpty ? '?' : widget.title[0].toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  Text(widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _switcher(int docCount) {
    Widget pill(String label, bool selected, VoidCallback onTap) => Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: selected ? Colors.white : AppColors.navy)),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          pill('Chat', !_docsView, () => setState(() => _docsView = false)),
          const SizedBox(width: 10),
          pill('Documents ($docCount)', _docsView,
                  () => setState(() => _docsView = true)),
        ],
      ),
    );
  }

  // ---------------- bubbles ----------------
  Widget _bubble(ChatMessage m) {
    final mine = m.senderUid == _uid;
    final bg = mine ? AppColors.primary : Colors.white;
    final fg = mine ? Colors.white : AppColors.navy;
    final sub = mine ? Colors.white70 : _muted;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(mine ? 20 : 5),
            bottomRight: Radius.circular(mine ? 5 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!mine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(m.senderName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.primary)),
              ),
            if (m.isFile)
              GestureDetector(
                onTap: () => _open(m),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (mine ? Colors.white : AppColors.primary)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_fileIcon(m.fileName),
                          color: mine ? Colors.white : AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: fg)),
                          Text('${_size(m.fileSize)} • Tap to open',
                              style: TextStyle(fontSize: 11, color: sub)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(m.text, style: TextStyle(color: fg, height: 1.35)),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(_time(m.createdAt),
                  style: TextStyle(fontSize: 10, color: sub)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docCard(ChatMessage m) => GestureDetector(
    onTap: () => _open(m),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_fileIcon(m.fileName), color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
                const SizedBox(height: 2),
                Text(
                    '${m.senderUid == _uid ? 'You' : m.senderName} • ${_size(m.fileSize)} • ${_dateTime(m.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: _muted)),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, color: AppColors.primary, size: 20),
        ],
      ),
    ),
  );

  Widget _empty(IconData icon, String title, String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted)),
        ],
      ),
    ),
  );

  // ---------------- input bar ----------------
  Widget _inputBar() => Container(
    padding: EdgeInsets.fromLTRB(
        12, 10, 12, 10 + MediaQuery.of(context).padding.bottom * 0.5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.10),
          blurRadius: 20,
          offset: const Offset(0, -6),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          IconButton(
            onPressed: _uploading ? null : _attach,
            icon: const Icon(Icons.attach_file_rounded,
                color: AppColors.primary),
          ),
          Expanded(
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Write a message',
                filled: true,
                fillColor: _bg,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendText,
            child: Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF7468EE), AppColors.primaryDark],
                ),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _uploadBanner() => Container(
    margin: const EdgeInsets.fromLTRB(20, 4, 20, 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Uploading $_uploadingName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            minHeight: 6,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return _empty(Icons.error_outline, 'Could not load chat',
                      '${snap.error}');
                }
                if (!snap.hasData) {
                  return const Center(
                      child:
                      CircularProgressIndicator(color: AppColors.primary));
                }
                final all = snap.data!;
                final docs = all.where((m) => m.isFile).toList();

                Widget body;
                if (_docsView) {
                  body = docs.isEmpty
                      ? _empty(Icons.folder_open, 'No documents yet',
                      'Tap the paperclip in Chat to share your proposal, report or slides.')
                      : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    children: docs.map(_docCard).toList(),
                  );
                } else {
                  body = all.isEmpty
                      ? _empty(Icons.chat_bubble_outline, 'Start the conversation',
                      'Say hello and share your FYP updates.')
                      : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    itemCount: all.length,
                    itemBuilder: (_, i) => _bubble(all[i]),
                  );
                }

                return Column(
                  children: [
                    _switcher(docs.length),
                    if (_uploading) _uploadBanner(),
                    Expanded(child: body),
                  ],
                );
              },
            ),
          ),
          if (!_docsView) _inputBar(),
        ],
      ),
    );
  }
}