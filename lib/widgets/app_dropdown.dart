import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const AppDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.navy)),
          ),
          DropdownButtonFormField<String>(
            value: items.contains(value) ? value : null,
            isExpanded: true,
            borderRadius: BorderRadius.circular(18),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.primary),
            ),
            items: items
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e, overflow: TextOverflow.ellipsis),
            ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}