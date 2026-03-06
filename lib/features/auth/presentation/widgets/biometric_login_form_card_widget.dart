// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/services/auth/biometric_login_service.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BiometricLoginFormCard extends ConsumerStatefulWidget {
  const BiometricLoginFormCard({super.key});

  @override
  ConsumerState<BiometricLoginFormCard> createState() =>
      _BiometricLoginFormCardState();
}

class _BiometricLoginFormCardState
    extends ConsumerState<BiometricLoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  BiometricLoginAvailability? _availability;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    final availability = await ref
        .read(biometricLoginServiceProvider)
        .getAvailability();
    if (!mounted) return;
    setState(() {
      _availability = availability;
      _isLoading = false;
    });
  }

  Future<void> _enableBiometricLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(userSessionServiceProvider);
    final email = session.getCurrentUserEmail()?.trim() ?? '';
    final password = _passwordController.text.trim();
    if (email.isEmpty) {
      SnackbarUtils.showError(
        context,
        'Current account email is missing. Please sign in again first.',
      );
      return;
    }

    setState(() => _isSaving = true);

    final loginResult = await ref
        .read(loginUseCaseProvider)
        .call(LoginUseCaseParams(email: email, password: password));

    final didVerifyPassword = loginResult.isRight();
    if (!didVerifyPassword) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      loginResult.fold(
        (failure) => SnackbarUtils.showError(context, failure.message),
        (_) {},
      );
      return;
    }

    final didAuthenticate = await ref
        .read(biometricLoginServiceProvider)
        .authenticateForEnrollment();
    if (!didAuthenticate) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackbarUtils.showInfo(
        context,
        'Biometric confirmation was cancelled or is not available.',
      );
      return;
    }

    await ref
        .read(biometricLoginServiceProvider)
        .saveCredentials(email: email, password: password);

    _passwordController.clear();
    await _loadAvailability();
    if (!mounted) return;
    setState(() => _isSaving = false);
    SnackbarUtils.showSuccess(
      context,
      'Biometric login enabled for this device.',
    );
  }

  Future<void> _disableBiometricLogin() async {
    setState(() => _isSaving = true);
    await ref.read(biometricLoginServiceProvider).clearCredentials();
    _passwordController.clear();
    await _loadAvailability();
    if (!mounted) return;
    setState(() => _isSaving = false);
    SnackbarUtils.showSuccess(context, 'Biometric login disabled.');
  }

  @override
  Widget build(BuildContext context) {
    final availability = _availability;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.fingerprint_rounded,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Biometric Login',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    availability == null ||
                            !availability.isDeviceSupported ||
                            !availability.canCheckBiometrics
                        ? 'Biometric login is not available on this device.'
                        : availability.hasSavedCredentials
                        ? 'Biometric login is enabled on this device. You can use your device biometrics to sign in faster.'
                        : 'Enable biometric login for this device. We will verify your account password once before activation.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (availability != null &&
                      availability.isDeviceSupported &&
                      availability.canCheckBiometrics) ...[
                    const SizedBox(height: 16),
                    if (!availability.hasSavedCredentials) ...[
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            MyTextFormField(
                              controller: _passwordController,
                              text: 'Enter current password',
                              inputType: TextInputType.visiblePassword,
                              obscureText: true,
                              validationErrorMessage:
                                  'Current password is required',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Kaarya can only verify that the signed-in biometric belongs to this device. Mobile apps cannot identify one exact fingerprint versus another enrolled fingerprint.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textLight),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: MyButton(
                                text: 'Enable Fingerprint Login',
                                onPressed: _enableBiometricLogin,
                                isLoading: _isSaving,
                                icon: const Icon(
                                  LucideIcons.shieldCheck,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      if ((availability.savedEmail ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Enabled for ${availability.savedEmail}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: MyButton(
                          text: 'Disable Biometric Login',
                          onPressed: _disableBiometricLogin,
                          isLoading: _isSaving,
                          variant: ButtonVariant.secondary,
                          icon: const Icon(
                            LucideIcons.circleOff,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
      ),
    );
  }
}
