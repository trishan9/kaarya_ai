import 'package:flutter/material.dart';
import 'package:kaarya/features/splash/presentation/pages/splash_page.dart';
import 'package:kaarya/app/theme/theme_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashPage(),
      title: "Kaarya.ai",
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
    );
  }
}
