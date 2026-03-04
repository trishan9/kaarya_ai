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
import 'package:kaarya/features/auth/presentation/widgets/login_text_widget.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        return SnackbarUtils.showError(
          context,
          "Password and Confirm Password must be same!",
        );
      }

      ref
          .read(authViewModelProvider.notifier)
          .registerUser(
            name: _fullNameController.text,
            email: _emailAddressController.text,
            password: _passwordController.text,
          );
    }
  }

  Future<void> _handleGoogleSignup() async {
    SnackbarUtils.showSuccess(context, "Signup with Google Successful");
  }

  Future<void> _handleGithubSignup() async {
    SnackbarUtils.showSuccess(context, "Signup with GitHub Successful");
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == previous?.status) return;

      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(
          context,
          next.errorMessage ??
              "Account created successfully, Proceed to login!",
        );

        ref.read(authViewModelProvider.notifier).resetState();

        AppRoutes.pop(context);
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Failed to create account, Please try again!",
        );

        ref.read(authViewModelProvider.notifier).resetState();
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
                HeaderSection(),

                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      HeadingWithSubheadingWidget(
                        heading: "Create Your Account",
                        subheading:
                            "Welcome to Kaarya! Let's get started by creating your account.",
                      ),

                      const SizedBox(height: 36),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 14,
                        children: [
                          MyTextFormField(
                            controller: _fullNameController,
                            text: "Enter your full name",
                            inputType: TextInputType.name,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.grey,
                            ),
                            validationErrorMessage: "Full name is required",
                          ),

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

                          MyTextFormField(
                            controller: _passwordController,
                            text: "Enter your password",
                            obscureText: true,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.grey,
                            ),
                            validationErrorMessage: "Password is required",
                          ),

                          MyTextFormField(
                            controller: _confirmPasswordController,
                            text: "Confirm your password",
                            obscureText: true,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.grey,
                            ),
                            validationErrorMessage:
                                "Confirm Password is required",
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      MyButton(
                        text: "Sign Up",
                        onPressed: _handleSignup,
                        isLoading: authState.status == AuthStatus.loading,
                      ),

                      const SizedBox(height: 24),

                      TextDividerWidget(text: "Or"),

                      const SizedBox(height: 24),

                      Column(
                        spacing: 12,
                        children: [
                          MyButton(
                            onPressed: _handleGoogleSignup,
                            text: "Signup with Google",
                            variant: ButtonVariant.secondary,
                            icon: Image.asset("assets/images/google_logo.png"),
                          ),

                          MyButton(
                            onPressed: _handleGithubSignup,
                            text: "Signup with GitHub",
                            variant: ButtonVariant.secondary,
                            icon: Image.asset("assets/images/github_logo.png"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                LoginText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
