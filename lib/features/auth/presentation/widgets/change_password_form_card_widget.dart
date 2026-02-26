import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChangePasswordFormCard extends ConsumerStatefulWidget {
  const ChangePasswordFormCard({super.key});

  @override
  ConsumerState<ChangePasswordFormCard> createState() =>
      _ChangePasswordFormCardState();
}

class _ChangePasswordFormCardState extends ConsumerState<ChangePasswordFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 12) {
      return 'Must be at least 12 characters';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must include a lowercase letter';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must include an uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must include a number';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Must include a symbol';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authViewModelProvider.notifier).changePassword(
          currentPassword: _currentPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
          confirmNewPassword: _confirmPasswordController.text.trim(),
        );

    if (mounted) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.keyRound, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Change Password',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Update your password. You will receive a confirmation email after the change.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MyTextFormField(
                    controller: _currentPasswordController,
                    text: 'Enter current password',
                    inputType: TextInputType.visiblePassword,
                    obscureText: true,
                    validationErrorMessage: 'Current password is required',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'New Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MyTextFormField(
                    controller: _newPasswordController,
                    text: 'Enter new password',
                    inputType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: _validateNewPassword,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Min 12 chars with uppercase, lowercase, number, and symbol.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Confirm New Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MyTextFormField(
                    controller: _confirmPasswordController,
                    text: 'Re-enter new password',
                    inputType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MyButton(
                      text: 'Change Password',
                      onPressed: _handleSubmit,
                      isLoading: isLoading,
                      icon: Icon(LucideIcons.keyRound, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
