import 'package:flutter/material.dart';
import 'package:kaarya/app/routes/app_routes.dart';
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontFamily: "GeneralSans",
          ),
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: Color(0xFF0084D1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
