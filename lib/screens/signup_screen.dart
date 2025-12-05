import 'package:flutter/material.dart';
import 'package:kaarya/common/my_snackbar.dart';
import 'package:kaarya/screens/login_screen.dart';
import 'package:kaarya/screens/onboarding_screen.dart';
import 'package:kaarya/widgets/header_section_widget.dart';
import 'package:kaarya/widgets/heading_with_subheading_widget.dart';
import 'package:kaarya/widgets/my_button_widget.dart';
import 'package:kaarya/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/widgets/text_divider_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeaderSection(),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    HeadingWithSubheadingWidget(
                      heading: "Create Your Account",
                      subheading:
                          "Welcome to Kaarya! Let's get started by creating your account.",
                    ),

                    SizedBox(height: 36),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 14,
                      children: [
                        MyTextFormField(
                          controller: _fullNameController,
                          text: "Enter your full name",
                          inputType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: Colors.grey,
                          ),
                          validationErrorMessage: "Full name is required",
                        ),

                        MyTextFormField(
                          controller: _emailAddressController,
                          text: "Enter your email address",
                          inputType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: Colors.grey,
                          ),
                          validationErrorMessage: "Email address is required",
                        ),

                        MyTextFormField(
                          controller: _passwordController,
                          text: "Enter your password",
                          obscureText: true,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.grey,
                          ),
                          validationErrorMessage: "Password is required",
                        ),

                        MyTextFormField(
                          controller: _confirmPasswordController,
                          text: "Confirm your password",
                          obscureText: true,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.grey,
                          ),
                          validationErrorMessage:
                              "Confirm Password is required",
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    MyButton(
                      text: "Sign Up",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showMySnackBar(
                            context: context,
                            message: "Account created successfully",
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnboardingScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                    ),

                    SizedBox(height: 24),

                    TextDividerWidget(text: "Or"),

                    SizedBox(height: 24),

                    // Social logins
                    Column(
                      spacing: 12,
                      children: [
                        MyButton(
                          onPressed: () {
                            showMySnackBar(
                              context: context,
                              message: "Signup with Google Successful",
                            );
                          },
                          text: "Signup with Google",
                          variant: ButtonVariant.secondary,
                          icon: Image.asset("assets/images/google_logo.png"),
                        ),

                        MyButton(
                          onPressed: () {
                            showMySnackBar(
                              context: context,
                              message: "Signup with GitHub Successful",
                            );
                          },
                          text: "Signup with GitHub",
                          variant: ButtonVariant.secondary,
                          icon: Image.asset("assets/images/github_logo.png"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              LoginText(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginText extends StatelessWidget {
  const LoginText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
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
