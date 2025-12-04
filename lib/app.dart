import 'package:flutter/material.dart';
import 'package:kaarya/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      title: "Kaarya.ai",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'GeneralSans'),
    );
  }
}
