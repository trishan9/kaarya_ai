import 'package:flutter/material.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/features/auth/presentation/pages/login_page.dart';
import 'package:kaarya/features/onboarding/data/models/onboarding_data_model.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
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
          "Monitor applications, interviews, feedback, and more — all in one place.",
      image: "assets/images/onboarding4.png",
    ),
  ];

  final PageController _controller = PageController();
  int currentIndex = 0;

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
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                page.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 1),

                              Text(
                                page.subtitle,
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                color: Colors.white,
                              ),
                              child: Image.asset(page.image, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentIndex != 0) ...{
                    MyButton(
                      variant: ButtonVariant.text,
                      btnWidth: 180,
                      onPressed: () {
                        _controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      text: "Previous",
                    ),
                  } else ...{
                    const SizedBox(width: 180),
                  },

                  MyButton(
                    btnWidth: 180,
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
