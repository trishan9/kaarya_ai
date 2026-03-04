import 'package:flutter/material.dart';

class MyTextFormField extends StatefulWidget {
  const MyTextFormField({
    super.key,
    this.controller,
    required this.text,
    this.inputType = TextInputType.text,
    this.validationErrorMessage = "Please enter some value",
    this.prefixIcon,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.optional = false,
  });

  final TextEditingController? controller;
  final String text;
  final TextInputType inputType;
  final String validationErrorMessage;

  final Widget? prefixIcon;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool optional;

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.inputType,
      obscureText: widget.obscureText ? _isObscured : false,
      onChanged: widget.onChanged,
      style: const TextStyle(letterSpacing: 0),

      validator:
          widget.validator ??
          (value) {
            if (!widget.optional && (value == null || value.isEmpty)) {
              return widget.validationErrorMessage;
            }
            return null;
          },

      decoration: InputDecoration(
        hintText: widget.text,
        hintStyle: const TextStyle(letterSpacing: 0),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
      ),
    );
  }
}
