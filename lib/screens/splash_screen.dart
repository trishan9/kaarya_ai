import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/kaarya_logo.png', width: 110),
              Text(
                "Kaarya.ai",
                style: TextStyle(fontSize: 52, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 100),
              CircularProgressIndicator(
                color: Color.fromRGBO(4, 113, 182, 1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
