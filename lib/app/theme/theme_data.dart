import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaarya/app/theme/app_colors.dart';

ThemeData getApplicationTheme() => getLightApplicationTheme();

ThemeData getLightApplicationTheme() => _buildTheme(isDark: false);

ThemeData getDarkApplicationTheme() => _buildTheme(isDark: true);

ThemeData _buildTheme({required bool isDark}) {
  final base = GoogleFonts.spaceGroteskTextTheme();
  final scaffold = isDark ? const Color(0xFF060A0F) : Colors.white;
  final surface = isDark ? const Color(0xFF0F141B) : Colors.white;
  final elevatedSurface = isDark
      ? const Color(0xFF111922)
      : const Color(0xFFF8F9FA);
  final border = isDark ? const Color(0xFF1E2A38) : AppColors.borderStroke;
  final textPrimary = isDark ? const Color(0xFFF5F7FA) : Colors.black;
  final textSecondary = isDark ? const Color(0xFF9BA9BA) : AppColors.textLight;

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        surface: surface,
        onSurface: textPrimary,
        secondaryContainer: isDark
            ? const Color(0xFF102233)
            : AppColors.bgSecondary,
        outline: border,
        onPrimary: Colors.white,
      );

  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffold,
    canvasColor: surface,
    cardColor: surface,
    primarySwatch: AppColors.primarySwatch,
    textTheme: base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        letterSpacing: 0,
        color: textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(letterSpacing: 0, color: textPrimary),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textPrimary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textSecondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        letterSpacing: 0,
        color: textPrimary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        letterSpacing: 0,
        color: textSecondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        letterSpacing: 0,
        color: textSecondary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      leadingWidth: 60,
      titleSpacing: 4,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
      ),
      shadowColor: Colors.transparent,
      surfaceTintColor: surface,
      iconTheme: IconThemeData(color: textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(10),
      filled: true,
      fillColor: elevatedSurface,
      hintStyle: GoogleFonts.spaceGrotesk(
        letterSpacing: 0,
        color: textSecondary,
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: border),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: surface,
      elevation: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: textSecondary,
      selectedIconTheme: const IconThemeData(
        size: 24,
        color: AppColors.primary,
      ),
      unselectedIconTheme: IconThemeData(size: 24, color: textSecondary),
      showUnselectedLabels: false,
      showSelectedLabels: false,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: isDark ? const Color(0xFF0B1118) : Colors.white,
      width: 300,
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 20),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
