import 'package:flutter/material.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/features/auth/presentation/pages/login_page.dart';
import 'package:kaarya/features/onboarding/data/models/onboarding_data_model.dart';
import 'package:kaarya/features/onboarding/presentation/widgets/onboarding_progress_widget.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final List<OnboardingDataModel> onboardingPages = [
    OnboardingDataModel(
      title: "Find Your Perfect Job Match",
      subtitle:
          "Our dashboard streamlines your career journey with personalized job recommendations.",
      image: "assets/images/onboarding1.png",
    ),
    OnboardingDataModel(
      title: "Explore Jobs & Internships",
      subtitle:
          "Discover opportunities tailored to your interests, skills, and location.",
      image: "assets/images/onboarding2.png",
    ),
    OnboardingDataModel(
      title: "Mock Interviews With AI",
      subtitle:
          "Practice real interview questions and improve instantly with AI feedback.",
      image: "assets/images/onboarding3.png",
    ),
    OnboardingDataModel(
      title: "Track Your Career Progress",
      subtitle:
          "Monitor applications, interviews, feedback, and more all in one place.",
      image: "assets/images/onboarding4.png",
    ),
  ];

  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            OnboardingProgress(index: currentIndex),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingPages.length,
                onPageChanged: (i) {
                  setState(() => currentIndex = i);
                },
                itemBuilder: (context, index) {
                  final page = onboardingPages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              page.title,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              page.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textLight,
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Image.asset(
                                  page.image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: currentIndex == 0
                        ? const SizedBox()
                        : OutlinedButton(
                            onPressed: () {
                              _controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                            child: const Text('Previous'),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      onPressed: () {
                        if (currentIndex == onboardingPages.length - 1) {
                          AppRoutes.pushReplacement(context, const LoginPage());
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      text: currentIndex == onboardingPages.length - 1
                          ? "Get Started"
                          : "Next",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
