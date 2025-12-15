import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaarya/theme/theme_data.dart';

Widget buildIcon({
  required String assetPath,
  required bool isActive,
  double? width,
  double? height,
}) {
  final theme = getApplicationTheme().bottomNavigationBarTheme;
  final color = isActive ? theme.selectedItemColor : theme.unselectedItemColor;

  return SvgPicture.asset(
    assetPath,
    width: width ?? 24,
    height: height ?? 24,
    colorFilter: ColorFilter.mode(color ?? Colors.grey, BlendMode.srcIn),
  );
}
