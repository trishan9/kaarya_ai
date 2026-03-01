import 'package:flutter/material.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/auth/presentation/pages/signup_page.dart';

class SignupText extends StatelessWidget {
  const SignupText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppRoutes.push(context, const SignupPage());
      },

      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textDark),
          children: [
            TextSpan(
              text: "Sign Up",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
