import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    this.obscureText = false,
    this.icon,
    this.suffixIcon,
    this.autofocus = false,
    this.hintText,
    required this.validator,
    this.autocorrect = true,
    required this.onSaved,
    this.enableSuggestions = true,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.outlineBorder = true,
    this.readOnly = false,
    this.onTap,
    this.controller,
  });

  final bool autofocus;
  final bool obscureText;
  final Widget? icon;
  final Widget? suffixIcon;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool autocorrect;
  final Function(String?)? onSaved;
  final bool enableSuggestions;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool outlineBorder;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
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
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: hintText,
          icon: icon,
          suffixIcon: suffixIcon,
          border: (outlineBorder) ? OutlineInputBorder() : null,
        ),
      ),
    );
  }
}
