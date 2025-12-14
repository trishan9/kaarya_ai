import 'package:flutter/material.dart';
import 'package:kaarya/screens/splash_screen.dart';
import 'package:kaarya/theme/theme_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      title: "Kaarya.ai",
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
    );
  }
}
