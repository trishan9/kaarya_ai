import 'package:flutter/material.dart';
import 'package:kaarya/common/my_snackbar.dart';
import 'package:kaarya/screens/home_screen.dart';
import 'package:kaarya/screens/signup_screen.dart';
import 'package:kaarya/widgets/header_section_widget.dart';
import 'package:kaarya/widgets/heading_with_subheading_widget.dart';
import 'package:kaarya/widgets/my_button_widget.dart';
import 'package:kaarya/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/widgets/text_divider_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                      heading: "Welcome back to Kaarya!",
                      subheading:
                          "Enter your username and password to access your account",
                    ),

                    SizedBox(height: 36),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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

                        SizedBox(height: 14),

                        MyTextFormField(
                          controller: _passwordController,
                          inputType: TextInputType.visiblePassword,
                          text: "Enter your password",
                          obscureText: true,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.grey,
                          ),
                          validationErrorMessage: "Password is required",
                        ),

                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0084D1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    MyButton(
                      text: "Login",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showMySnackBar(
                            context: context,
                            message: "Login Successful",
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
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
                              message: "Login with Google Successful",
                            );
                          },
                          text: "Login with Google",
                          variant: ButtonVariant.secondary,
                          icon: Image.asset("assets/images/google_logo.png"),
                        ),

                        MyButton(
                          onPressed: () {
                            showMySnackBar(
                              context: context,
                              message: "Login with GitHub Successful",
                            );
                          },
                          text: "Login with GitHub",
                          variant: ButtonVariant.secondary,
                          icon: Image.asset("assets/images/github_logo.png"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SignupText(),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupText extends StatelessWidget {
  const SignupText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignupScreen()),
        );
      },
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontFamily: "GeneralSans",
          ),
          children: [
            TextSpan(
              text: "Sign Up",
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
