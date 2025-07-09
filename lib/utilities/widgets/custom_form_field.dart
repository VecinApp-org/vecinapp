import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    this.obscureText = false,
    this.icon,
    this.suffixIcon,
    this.autofocus = false,
    required this.hintText,
    required this.validator,
    this.autocorrect = true,
    this.onSaved,
    this.enableSuggestions = true,
    this.keyboardType,
    this.maxLength,
    this.maxLines,
    this.minLines,
  });

  final bool autofocus;
  final bool obscureText;
  final Widget? icon;
  final Widget? suffixIcon;
  final String hintText;
  final String? Function(String?)? validator;
  final bool autocorrect;
  final Function(String?)? onSaved;
  final bool enableSuggestions;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: minLines,
        obscureText: obscureText,
        validator: validator,
        autofocus: autofocus,
        enableSuggestions: enableSuggestions,
        onSaved: onSaved,
        keyboardType: keyboardType,
        autocorrect: autocorrect,
        decoration: InputDecoration(
          labelText: hintText,
          icon: icon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
