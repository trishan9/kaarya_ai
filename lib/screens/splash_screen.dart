import 'package:flutter/material.dart';
import 'package:kaarya/widgets/app_logo_widget.dart';
import 'package:kaarya/widgets/loader_widget.dart';

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
