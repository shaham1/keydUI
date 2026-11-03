import 'package:flutter/material.dart';
import 'package:keydui/core/theme/app_palette.dart';

class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final IconData? prefixIcon;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.prefixIcon,
    this.onSubmitted,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      style: const TextStyle(
        color: Palette.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'monospace',
        letterSpacing: 0.5,
      ),
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  widget.prefixIcon,
                  color: Palette.textSecondary,
                  size: 22,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: Palette.minTouchTarget,
          minHeight: Palette.minTouchTarget,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                constraints: const BoxConstraints(
                  minWidth: Palette.minTouchTarget,
                  minHeight: Palette.minTouchTarget,
                ),
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Palette.textSecondary,
                  size: 22,
                ),
                tooltip: _obscureText ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
