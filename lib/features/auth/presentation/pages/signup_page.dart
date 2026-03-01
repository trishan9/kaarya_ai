import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/core/widgets/text_divider_widget.dart';
import 'package:kaarya/features/auth/presentation/pages/login_page.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kaarya/features/auth/presentation/widgets/header_section_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/heading_with_subheading_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/login_text_widget.dart';

enum _SignupRole { candidate, recruiter, college }

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailAddressController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _designationController = TextEditingController();
  final _companyLocationController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _institutionTypeController = TextEditingController();
  final _collegeLocationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _SignupRole _selectedRole = _SignupRole.candidate;
  bool _isSubmitting = false;
  bool _showValidationErrors = false;

  String get _signupButtonText => switch (_selectedRole) {
    _SignupRole.candidate => 'Sign Up',
    _SignupRole.recruiter => 'Create Recruiter Account',
    _SignupRole.college => 'Create College Account',
  };

  String get _roleDescription => switch (_selectedRole) {
    _SignupRole.candidate => 'Candidate signup creates your personal account.',
    _SignupRole.recruiter =>
      'Recruiter signup creates your account first. You can create your workspace after signing in.',
    _SignupRole.college =>
      'College signup creates your account first. You can create your workspace after signing in.',
  };

  String get _apiRole => switch (_selectedRole) {
    _SignupRole.candidate => 'user',
    _SignupRole.recruiter => 'recruiter',
    _SignupRole.college => 'college',
  };

  bool get _isCandidate => _selectedRole == _SignupRole.candidate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailAddressController.dispose();
    _companyNameController.dispose();
    _industryController.dispose();
    _designationController.dispose();
    _companyLocationController.dispose();
    _collegeNameController.dispose();
    _institutionTypeController.dispose();
    _collegeLocationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final required = _validateRequired(value, 'Email address is required');
    if (required != null) {
      return required;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim().toLowerCase())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final required = _validateRequired(value, 'Password is required');
    if (required != null) {
      return required;
    }
    if (value!.trim().length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();

    if (!_showValidationErrors) {
      setState(() {
        _showValidationErrors = true;
      });
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      SnackbarUtils.showError(
        context,
        'Password and confirm password must match.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authNotifier = ref.read(authViewModelProvider.notifier);
    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();

    await authNotifier.registerUser(
      name: fullName,
      email: _emailAddressController.text.trim().toLowerCase(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      role: _apiRole,
    );

    final registerState = ref.read(authViewModelProvider);
    if (registerState.status == AuthStatus.error) {
      authNotifier.resetState();
      if (mounted) {
        SnackbarUtils.showError(
          context,
          registerState.errorMessage ?? 'Failed to create account.',
        );
      }
      _setSubmitting(false);
      return;
    }

    authNotifier.resetState();

    if (mounted) {
      SnackbarUtils.showSuccess(
        context,
        'Signup successful. Please sign in to continue.',
      );
      AppRoutes.pushReplacement(context, const LoginPage());
    }
    _setSubmitting(false);
  }

  void _setSubmitting(bool value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = value;
    });
  }

  Future<void> _handleGoogleSignup() async {
    SnackbarUtils.showSuccess(context, 'Signup with Google Successful');
  }

  Future<void> _handleGithubSignup() async {
    SnackbarUtils.showSuccess(context, 'Signup with GitHub Successful');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final topSpacing = width >= 640 ? 86.0 : 48.0;
            final horizontalPadding = width >= 640 ? 28.0 : 18.0;
            final verticalPadding = width >= 640 ? 20.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      width >= 640 ? 28 : 18,
                      18,
                      width >= 640 ? 28 : 18,
                      24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderStroke2),
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _showValidationErrors
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HeaderSection(),
                          SizedBox(height: topSpacing),
                          const HeadingWithSubheadingWidget(
                            heading: 'Create your account',
                            subheading:
                                'Choose candidate or recruiter signup and get started on Kaarya.',
                          ),
                          const SizedBox(height: 28),
                          const _FieldLabel('Sign up as'),
                          const SizedBox(height: 10),
                          _RoleSwitcher(
                            role: _selectedRole,
                            onChanged: (role) {
                              setState(() {
                                _selectedRole = role;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Text(
                              _roleDescription,
                              key: ValueKey(_selectedRole),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textLight,
                                    height: 1.6,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildTwoColumnRow(
                            width: width,
                            left: _buildFormField(
                              label: 'First Name',
                              controller: _firstNameController,
                              hintText: 'Trishan',
                              validator: (value) => _validateRequired(
                                value,
                                'First name is required',
                              ),
                            ),
                            right: _buildFormField(
                              label: 'Last Name',
                              controller: _lastNameController,
                              hintText: 'Wagle',
                              validator: (value) => _validateRequired(
                                value,
                                'Last name is required',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Email',
                            controller: _emailAddressController,
                            hintText: 'trishan@kaarya.com',
                            inputType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _buildRoleFields(width),
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Password',
                            controller: _passwordController,
                            hintText: '',
                            obscureText: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Confirm Password',
                            controller: _confirmPasswordController,
                            hintText: '',
                            obscureText: true,
                            validator: (value) {
                              final required = _validateRequired(
                                value,
                                'Confirm password is required',
                              );
                              if (required != null) {
                                return required;
                              }
                              if (value!.trim() !=
                                  _passwordController.text.trim()) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          MyButton(
                            text: _signupButtonText,
                            onPressed: _handleSignup,
                            isLoading: _isSubmitting,
                          ),
                          if (_isCandidate) ...[
                            const SizedBox(height: 24),
                            const TextDividerWidget(text: 'Or'),
                            const SizedBox(height: 24),
                            Column(
                              spacing: 8,
                              children: [
                                MyButton(
                                  onPressed: _handleGoogleSignup,
                                  text: 'Signup with Google',
                                  variant: ButtonVariant.secondary,
                                  icon: Image.asset(
                                    'assets/images/google_logo.png',
                                  ),
                                ),
                                MyButton(
                                  onPressed: _handleGithubSignup,
                                  text: 'Signup with GitHub',
                                  variant: ButtonVariant.secondary,
                                  icon: Image.asset(
                                    'assets/images/github_logo.png',
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 26),
                          const Center(child: LoginText()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleFields(double width) {
    if (_selectedRole == _SignupRole.recruiter) {
      return Padding(
        key: const ValueKey('recruiter-fields'),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(
              label: 'Company Name',
              controller: _companyNameController,
              hintText: 'Kaarya AI',
              validator: (value) =>
                  _validateRequired(value, 'Company name is required'),
            ),
            const SizedBox(height: 16),
            _buildTwoColumnRow(
              width: width,
              left: _buildFormField(
                label: 'Industry',
                controller: _industryController,
                hintText: 'Technology',
                validator: (value) =>
                    _validateRequired(value, 'Industry is required'),
              ),
              right: _buildFormField(
                label: 'Designation',
                controller: _designationController,
                hintText: 'Talent Partner',
                validator: (value) =>
                    _validateRequired(value, 'Designation is required'),
              ),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              label: 'Location',
              controller: _companyLocationController,
              hintText: 'Kathmandu, Nepal',
              validator: (value) =>
                  _validateRequired(value, 'Location is required'),
            ),
          ],
        ),
      );
    }

    if (_selectedRole == _SignupRole.college) {
      return Padding(
        key: const ValueKey('college-fields'),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(
              label: 'College Name',
              controller: _collegeNameController,
              hintText: 'Softwarica College of IT',
              validator: (value) =>
                  _validateRequired(value, 'College name is required'),
            ),
            const SizedBox(height: 16),
            _buildTwoColumnRow(
              width: width,
              left: _buildFormField(
                label: 'Institution Type',
                controller: _institutionTypeController,
                hintText: 'Engineering College',
                validator: (value) =>
                    _validateRequired(value, 'Institution type is required'),
              ),
              right: _buildFormField(
                label: 'Location',
                controller: _collegeLocationController,
                hintText: 'Kathmandu, Nepal',
                validator: (value) =>
                    _validateRequired(value, 'Location is required'),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(key: ValueKey('candidate-fields'), height: 0);
  }

  Widget _buildTwoColumnRow({
    required double width,
    required Widget left,
    required Widget right,
  }) {
    if (width < 390) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [left, const SizedBox(height: 16), right],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 10),
        MyTextFormField(
          controller: controller,
          text: hintText,
          inputType: inputType,
          obscureText: obscureText,
          validator: validator,
        ),
      ],
    );
  }
}

class _RoleSwitcher extends StatelessWidget {
  const _RoleSwitcher({required this.role, required this.onChanged});

  final _SignupRole role;
  final ValueChanged<_SignupRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _RoleSwitcherButton(
            label: 'Candidate',
            selected: role == _SignupRole.candidate,
            onTap: () => onChanged(_SignupRole.candidate),
          ),
          _RoleSwitcherButton(
            label: 'Recruiter',
            selected: role == _SignupRole.recruiter,
            onTap: () => onChanged(_SignupRole.recruiter),
          ),
          _RoleSwitcherButton(
            label: 'College',
            selected: role == _SignupRole.college,
            onTap: () => onChanged(_SignupRole.college),
          ),
        ],
      ),
    );
  }
}

class _RoleSwitcherButton extends StatelessWidget {
  const _RoleSwitcherButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: AppColors.borderStroke) : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }
}
