import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/core/widgets/text_divider_widget.dart';
import 'package:kaarya/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kaarya/features/auth/presentation/widgets/header_section_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/heading_with_subheading_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/signup_text_widget.dart';
import 'package:kaarya/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailAddressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
    AppRoutes.push(
      context,
      ForgotPasswordPage(initialEmail: _emailAddressController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == previous?.status) return;

      if (next.status == AuthStatus.authenticated) {
        ref.read(dashboardViewModelProvider.notifier).resetState();
        ref.read(authViewModelProvider.notifier).resetState();
        ref.invalidate(userSessionServiceProvider);
        AppRoutes.pushReplacement(context, const DashboardPage());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ref.read(authViewModelProvider.notifier).resetState();
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HeaderSection(),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const HeadingWithSubheadingWidget(
                        heading: "Welcome back to Kaarya!",
                        subheading:
                            "Enter your username and password to access your account",
                      ),
                      const SizedBox(height: 36),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MyTextFormField(
                            controller: _emailAddressController,
                            text: "Enter your email address",
                            inputType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: Colors.grey,
                            ),
                            validationErrorMessage: "Email address is required",
                          ),
                          const SizedBox(height: 14),
                          MyTextFormField(
                            controller: _passwordController,
                            inputType: TextInputType.visiblePassword,
                            text: "Enter your password",
                            obscureText: true,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.grey,
                            ),
                            validationErrorMessage: "Password is required",
                          ),
                          TextButton(
                            onPressed: _handleForgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: AppColors.primary,
                            ),
                            child: Text(
                              "Forgot Password?",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyButton(
                        text: "Login",
                        onPressed: _handleLogin,
                        isLoading: authState.status == AuthStatus.loading,
                      ),
                      const SizedBox(height: 24),
                      const TextDividerWidget(text: "Or"),
                      const SizedBox(height: 24),
                      Column(
                        spacing: 8,
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
                const SizedBox(height: 20),
                const SignupText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
