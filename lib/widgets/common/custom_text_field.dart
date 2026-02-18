import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  final Color? fillColor;
  final Color? textColor;
  final Color? borderColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.fillColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor ?? Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor?.withOpacity(0.7) ?? Colors.grey[700]),
        hintText: hint,
        hintStyle: TextStyle(color: textColor?.withOpacity(0.5) ?? Colors.grey[500]),
        prefixIcon: Icon(prefixIcon, color: textColor?.withOpacity(0.7) ?? Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: fillColor ?? Colors.grey.shade50,
      ),
    );
  }
}
