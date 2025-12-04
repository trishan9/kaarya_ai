import 'package:flutter/material.dart';
import 'package:kaarya/screens/login_screen.dart';
import 'package:kaarya/widgets/app_logo_widget.dart';
import 'package:kaarya/widgets/loader_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _navigateToLoginScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _navigateToLoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLogoWidget(),

              Text(
                "Kaarya.ai",
                style: TextStyle(fontSize: 52, fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 100),

              LoaderWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
