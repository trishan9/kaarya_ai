import 'package:flutter/material.dart';
import 'package:kaarya/theme/app_colors.dart';

class MyTextFormField extends StatefulWidget {
  const MyTextFormField({
    super.key,
    required this.controller,
    required this.text,
    this.inputType = TextInputType.text,
    this.validationErrorMessage = "Please enter some value",
    this.prefixIcon,
    this.obscureText = false,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String text;
  final TextInputType inputType;
  final String validationErrorMessage;

  final Widget? prefixIcon;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

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

      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return widget.validationErrorMessage;
            }
            return null;
          },

      decoration: InputDecoration(
        hintText: widget.text,

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

        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderStroke),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
