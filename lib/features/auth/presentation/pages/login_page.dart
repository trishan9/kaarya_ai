import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kaarya/features/auth/presentation/widgets/header_section_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/heading_with_subheading_widget.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/core/widgets/text_divider_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/signup_text_widget.dart';
import 'package:kaarya/features/dashboard/presentation/pages/dashboard_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .loginUser(
            email: _emailAddressController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  Future<void> _handleGoogleLogin() async {
    SnackbarUtils.showSuccess(context, "Login with Google Successful");
  }

  Future<void> _handleGithubLogin() async {
    SnackbarUtils.showSuccess(context, "Login with GitHub Successful");
  }

  Future<void> _handleForgotPassword() async {
    SnackbarUtils.showInfo(context, "Coming soon!");
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == previous?.status) return;

      if (next.status == AuthStatus.authenticated) {
        ref.read(authViewModelProvider.notifier).resetState();
        AppRoutes.pushReplacement(context, const DashboardPage());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ref.read(authViewModelProvider.notifier).resetState();
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
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
                          onPressed: _handleForgotPassword,
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
                      onPressed: _handleLogin,
                      isLoading: authState.status == AuthStatus.loading,
                    ),

                    SizedBox(height: 24),

                    TextDividerWidget(text: "Or"),

                    SizedBox(height: 24),

                    // Social logins
                    Column(
                      spacing: 12,
                      children: [
                        MyButton(
                          onPressed: _handleGoogleLogin,
                          text: "Login with Google",
                          variant: ButtonVariant.secondary,
                          icon: Image.asset("assets/images/google_logo.png"),
                        ),

                        MyButton(
                          onPressed: _handleGithubLogin,
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
