import 'package:flutter/material.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/core/widgets/app_logo_widget.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/onboarding/presentation/pages/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void _navigateToLoginScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    AppRoutes.pushReplacement(context, const OnboardingPage());
  }

  @override
  void initState() {
    super.initState();
    _navigateToLoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
