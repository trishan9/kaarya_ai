import 'package:flutter/material.dart';
import 'package:kaarya/theme/app_colors.dart';

enum ButtonVariant { primary, secondary }

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.icon,
  });

  final VoidCallback onPressed;
  final String text;
  final ButtonVariant variant;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      backgroundColor: _getBackgroundColor(),
      textColor: _getTextColor(),
    );
  }

  // Variant color mapping
  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.bgLight;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return Colors.black;
    }
  }
}

class _BaseButton extends StatelessWidget {
  const _BaseButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],

            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
