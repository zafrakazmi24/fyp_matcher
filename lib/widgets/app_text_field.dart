import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

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
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _hidden,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(widget.icon, color: AppColors.primary),
              suffixIcon: widget.isPassword
                  ? IconButton(
                icon: Icon(
                    _hidden ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grey),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}