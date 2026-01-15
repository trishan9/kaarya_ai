import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/widgets/app_logo_widget.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kaarya/features/onboarding/presentation/pages/onboarding_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      AppRoutes.pushReplacement(context, const DashboardPage());
    } else {
      AppRoutes.pushReplacement(context, const OnboardingPage());
    }
  }

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
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
