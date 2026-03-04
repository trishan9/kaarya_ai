import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, text }

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.btnWidth,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final String text;
  final ButtonVariant variant;
  final Widget? icon;
  final double? btnWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _BaseButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      backgroundColor: _getBackgroundColor(isDark),
      textColor: _getTextColor(isDark),
      btnWidth: btnWidth,
      isLoading: isLoading,
    );
  }

  // Variant color mapping
  Color _getBackgroundColor(bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return isDark ? const Color(0xFF111922) : AppColors.bgLight;
      case ButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor(bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return isDark ? Colors.white : Colors.black;
      case ButtonVariant.text:
        return AppColors.primary;
    }
  }
}

class _BaseButton extends StatelessWidget {
  const _BaseButton({
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.btnWidth,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final double? btnWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: btnWidth ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          side: backgroundColor == Colors.transparent ? BorderSide.none : null,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 10)],

                  Text(text, style: TextStyle(color: textColor)),
                ],
              ),
      ),
    );
  }
}
