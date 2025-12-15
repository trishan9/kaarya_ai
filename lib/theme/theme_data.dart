import 'package:flutter/material.dart';
import 'package:kaarya/theme/app_colors.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    fontFamily: "GeneralSans",
    scaffoldBackgroundColor: Colors.white,
    primarySwatch: AppColors.primarySwatch,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      leadingWidth: 60,
      titleSpacing: 4,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        fontFamily: "GeneralSans",
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(10),
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

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey.shade600,
      selectedIconTheme: const IconThemeData(
        size: 24,
        color: AppColors.primary,
      ),
      unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey.shade600),
      showUnselectedLabels: false,
      showSelectedLabels: false,
    ),

    drawerTheme: DrawerThemeData(backgroundColor: Colors.white, width: 300),

    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
      space: 20,
    ),
  );
}
