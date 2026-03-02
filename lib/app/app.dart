import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/splash/presentation/pages/splash_page.dart';
import 'package:kaarya/app/theme/theme_mode_controller.dart';
import 'package:kaarya/app/theme/theme_data.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp(
      home: const SplashPage(),
      title: "Kaarya.ai",
      debugShowCheckedModeBanner: false,
      theme: getLightApplicationTheme(),
      darkTheme: getDarkApplicationTheme(),
      themeMode: themeMode,
    );
  }
}
