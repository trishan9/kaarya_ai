import 'package:flutter/material.dart';

bool isDarkMode(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color appSurfaceColor(BuildContext context) =>
    isDarkMode(context) ? const Color(0xFF0F141B) : Colors.white;

Color appMutedSurfaceColor(BuildContext context) =>
    isDarkMode(context) ? const Color(0xFF111922) : const Color(0xFFF8F9FA);

Color appSoftSurfaceColor(BuildContext context) =>
    isDarkMode(context) ? const Color(0xFF16212D) : const Color(0xFFE7F2F8);

Color appBorderColor(BuildContext context) =>
    isDarkMode(context) ? const Color(0xFF263446) : const Color(0xFFD0D2D4);

Color appSubtleBorderColor(BuildContext context) =>
    isDarkMode(context) ? const Color(0xFF1E2A38) : const Color(0xFFF0F0F0);

Color appTextPrimaryColor(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface;

Color appTextSecondaryColor(BuildContext context) =>
    isDarkMode(context) ? const Color(0xFF9BA9BA) : const Color(0xFF717686);

Color appOverlayColor(BuildContext context) => isDarkMode(context)
    ? Colors.black.withAlpha(140)
    : Colors.white.withAlpha(180);
