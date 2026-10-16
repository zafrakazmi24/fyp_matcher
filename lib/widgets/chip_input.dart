import 'package:flutter/material.dart';
import '../core/theme.dart';

class ChipInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;

  const ChipInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  State<ChipInput> createState() => _ChipInputState();
}

class _ChipInputState extends State<ChipInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final updated = [...widget.items];
    for (final part in _controller.text.split(',')) {
      final t = part.trim();
      if (t.isEmpty) continue;
      final exists =
      updated.any((e) => e.toLowerCase() == t.toLowerCase());
      if (!exists) updated.add(t);
    }
    _controller.clear();
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(widget.label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.navy)),
          ),
          TextField(
            controller: _controller,
            onSubmitted: (_) => _add(),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(widget.icon, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle,
                    color: AppColors.primary, size: 28),
                onPressed: _add,
              ),
            ),
          ),
          if (widget.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.items
                  .map((e) => Chip(
                label: Text(e,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                backgroundColor: AppColors.card,
                deleteIconColor: Colors.white70,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                onDeleted: () => widget.onChanged(
                    widget.items.where((x) => x != e).toList()),
              ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}