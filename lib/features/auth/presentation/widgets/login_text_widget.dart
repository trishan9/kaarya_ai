import 'package:flutter/material.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/auth/presentation/pages/login_page.dart';

class LoginText extends StatelessWidget {
  const LoginText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppRoutes.push(context, const LoginPage());
      },

      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textDark),
          children: [
            TextSpan(
              text: "Login",
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
