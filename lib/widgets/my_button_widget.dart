import 'package:flutter/material.dart';
import 'package:kaarya/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, text }

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.btnWidth,
  });

  final VoidCallback onPressed;
  final String text;
  final ButtonVariant variant;
  final Widget? icon;
  final double? btnWidth;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      backgroundColor: _getBackgroundColor(),
      textColor: _getTextColor(),
      btnWidth: btnWidth,
    );
  }

  // Variant color mapping
  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.bgLight;
      case ButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return Colors.black;
      case ButtonVariant.text:
        return AppColors.primary;
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
    this.btnWidth,
  });

  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final double? btnWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: btnWidth ?? double.infinity,
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
