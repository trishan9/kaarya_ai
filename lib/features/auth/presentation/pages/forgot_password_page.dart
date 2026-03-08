import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/features/auth/domain/usecases/confirm_reset_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:kaarya/features/auth/presentation/widgets/header_section_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/password_reset_otp_input_widget.dart';

enum _ForgotPasswordStep { verify, reset, done }

enum _ForgotPasswordAction { request, verify, resend, reset }

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({
    super.key,
    this.initialEmail,
    this.initialResetToken,
  });

  final String? initialEmail;
  final String? initialResetToken;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  static const _resendCooldownSeconds = 30;
  static const _signinRedirectDelay = Duration(milliseconds: 2200);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _ForgotPasswordStep _step = _ForgotPasswordStep.verify;
  _ForgotPasswordAction? _activeAction;

  String _otpValue = '';
  String _resetToken = '';
  bool _hasSentCode = false;
  int _resendSecondsLeft = 0;

  String? _emailError;
  String? _otpError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _sendCodeError;
  String? _sendCodeInfo;
  String? _resetError;

  Timer? _resendTimer;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _emailController.text = (widget.initialEmail ?? '').trim();
    _resetToken = (widget.initialResetToken ?? '').trim();
    if (_resetToken.isNotEmpty) {
      _step = _ForgotPasswordStep.reset;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    _redirectTimer?.cancel();
    super.dispose();
  }

  bool get _isBusy => _activeAction != null;

  String get _normalizedEmail => _emailController.text.trim().toLowerCase();

  String _friendlyFailureMessage(String message, {required String fallback}) {
    final normalized = message.trim();
    if (normalized.isEmpty ||
        normalized == 'Something went wrong.' ||
        normalized == 'Failed to request password reset!' ||
        normalized == 'Failed to verify OTP!' ||
        normalized == 'Failed to reset password!') {
      return fallback;
    }
    return normalized;
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) {
      return email;
    }
    final localPart = parts.first;
    final domain = parts.last;
    if (localPart.length <= 2) {
      return '${localPart.isEmpty ? '' : localPart[0]}*@$domain';
    }
    return '${localPart.substring(0, 2)}${'*' * (localPart.length - 2)}@$domain';
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return "Email address can't be empty.";
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Email address must be valid.';
    }
    return null;
  }

  String? _validateOtp(String value) {
    if (value.trim().isEmpty) {
      return 'Verification code is required.';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Verification code must be a 6 digit code.';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return "Password can't be empty.";
    }
    if (value.length < 12) {
      return 'Password must be at least 12 characters.';
    }
    if (value.length > 128) {
      return 'Password must be at most 128 characters.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must include a lowercase letter.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must include an uppercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must include a number.';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Password must include a symbol.';
    }
    if (value.contains(RegExp(r'\s'))) {
      return 'Password must not contain spaces.';
    }
    return null;
  }

  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your new password.';
    }
    if (password != confirmPassword) {
      return 'Please make sure your passwords match.';
    }
    return null;
  }

  bool _validateEmailField() {
    final error = _validateEmail(_emailController.text);
    setState(() {
      _emailError = error;
    });
    return error == null;
  }

  bool _validateOtpField() {
    final error = _validateOtp(_otpValue);
    setState(() {
      _otpError = error;
    });
    return error == null;
  }

  bool _validateResetFields() {
    final passwordError = _validatePassword(_passwordController.text);
    final confirmPasswordError = _validateConfirmPassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );

    setState(() {
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return passwordError == null && confirmPasswordError == null;
  }

  void _clearResendCooldown() {
    _resendTimer?.cancel();
    _resendTimer = null;
    if (mounted) {
      setState(() {
        _resendSecondsLeft = 0;
      });
    }
  }

  void _startResendCooldown() {
    _clearResendCooldown();
    setState(() {
      _resendSecondsLeft = _resendCooldownSeconds;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _resendSecondsLeft = 0;
        });
        return;
      }

      setState(() {
        _resendSecondsLeft -= 1;
      });
    });
  }

  void _scheduleSigninReturn() {
    _redirectTimer?.cancel();
    _redirectTimer = Timer(_signinRedirectDelay, _returnToSignin);
  }

  void _returnToSignin() {
    if (!mounted) {
      return;
    }
    _redirectTimer?.cancel();
    if (Navigator.of(context).canPop()) {
      AppRoutes.pop(context);
    }
  }

  Future<void> _requestCode({bool isResend = false}) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _sendCodeError = null;
      _sendCodeInfo = null;
      _otpError = null;
      _resetError = null;
    });

    if (!_validateEmailField()) {
      return;
    }

    setState(() {
      _activeAction = isResend
          ? _ForgotPasswordAction.resend
          : _ForgotPasswordAction.request;
    });

    final result = await ref.read(requestPasswordResetUseCaseProvider)(
      RequestPasswordResetParams(email: _normalizedEmail),
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        final message = _friendlyFailureMessage(
          failure.message,
          fallback:
              'Password reset is temporarily unavailable. Please try again in a moment.',
        );
        setState(() {
          _sendCodeError = message;
        });
        SnackbarUtils.showError(context, message);
      },
      (success) {
        if (!success) {
          const message = 'Could not send verification code. Please try again.';
          setState(() {
            _sendCodeError = message;
          });
          SnackbarUtils.showError(context, message);
          return;
        }

        setState(() {
          _hasSentCode = true;
          _otpValue = '';
          _otpError = null;
          _resetToken = '';
          _sendCodeInfo = isResend
              ? 'A new verification code has been sent.'
              : 'Verification code sent. Check your email inbox.';
        });
        _startResendCooldown();
        SnackbarUtils.showSuccess(
          context,
          isResend
              ? 'A new verification code was sent.'
              : 'Verification code sent.',
        );
      },
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _activeAction = null;
    });
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _sendCodeError = null;
      _resetError = null;
    });

    final isEmailValid = _validateEmailField();
    final isOtpValid = _validateOtpField();
    if (!isEmailValid || !isOtpValid) {
      return;
    }

    setState(() {
      _activeAction = _ForgotPasswordAction.verify;
    });

    final result = await ref.read(verifyResetOtpUseCaseProvider)(
      VerifyResetOtpParams(email: _normalizedEmail, otp: _otpValue.trim()),
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        final message = _friendlyFailureMessage(
          failure.message,
          fallback: 'We could not verify the code right now. Please try again.',
        );
        setState(() {
          _otpError = message;
        });
        SnackbarUtils.showError(context, message);
      },
      (token) {
        if (token.trim().isEmpty) {
          const message =
              'Reset verification failed. Please request a new code.';
          setState(() {
            _otpError = message;
          });
          SnackbarUtils.showError(context, message);
          return;
        }

        _clearResendCooldown();
        setState(() {
          _step = _ForgotPasswordStep.reset;
          _resetToken = token.trim();
          _hasSentCode = false;
          _sendCodeInfo = null;
          _sendCodeError = null;
          _otpError = null;
          _passwordController.clear();
          _confirmPasswordController.clear();
          _passwordError = null;
          _confirmPasswordError = null;
        });
        SnackbarUtils.showSuccess(context, 'Code verified.');
      },
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _activeAction = null;
    });
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _resetError = null;
    });

    if (_resetToken.isEmpty) {
      setState(() {
        _resetError = 'Reset session expired. Please verify the code again.';
        _step = _ForgotPasswordStep.verify;
      });
      SnackbarUtils.showError(
        context,
        'Reset session expired. Please verify the code again.',
      );
      return;
    }

    if (!_validateResetFields()) {
      return;
    }

    setState(() {
      _activeAction = _ForgotPasswordAction.reset;
    });

    final result = await ref.read(confirmResetUseCaseProvider)(
      ConfirmResetParams(
        token: _resetToken,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        final message = _friendlyFailureMessage(
          failure.message,
          fallback:
              'We could not reset your password right now. Please try again.',
        );
        setState(() {
          _resetError = message;
        });
        if (message.toLowerCase().contains('token')) {
          _backToVerification(showNotice: false);
        }
        SnackbarUtils.showError(context, message);
      },
      (success) {
        if (!success) {
          const message = 'Unable to reset password. Please try again.';
          setState(() {
            _resetError = message;
          });
          SnackbarUtils.showError(context, message);
          return;
        }

        setState(() {
          _step = _ForgotPasswordStep.done;
          _resetToken = '';
          _resetError = null;
        });
        _scheduleSigninReturn();
        SnackbarUtils.showSuccess(context, 'Password reset successful.');
      },
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _activeAction = null;
    });
  }

  void _useDifferentEmail() {
    _clearResendCooldown();
    setState(() {
      _emailController.clear();
      _otpValue = '';
      _resetToken = '';
      _hasSentCode = false;
      _emailError = null;
      _otpError = null;
      _sendCodeError = null;
      _sendCodeInfo = null;
      _resetError = null;
      _step = _ForgotPasswordStep.verify;
    });
    SnackbarUtils.showInfo(context, 'Enter another email to continue.');
  }

  void _backToVerification({bool showNotice = true}) {
    _clearResendCooldown();
    setState(() {
      _step = _ForgotPasswordStep.verify;
      _hasSentCode = false;
      _otpValue = '';
      _resetToken = '';
      _otpError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _resetError = null;
      _sendCodeInfo = null;
      _sendCodeError = null;
    });
    if (showNotice) {
      SnackbarUtils.showInfo(context, 'Back to verification.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = width >= 640 ? 28.0 : 20.0;
            final verticalPadding = width >= 640 ? 20.0 : 16.0;
            final topSpacing = width >= 640 ? 88.0 : 48.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HeaderSection(),
                        SizedBox(height: topSpacing),
                        _buildHeader(theme),
                        const SizedBox(height: 28),
                        _ForgotPasswordStepper(step: _step),
                        const SizedBox(height: 28),
                        if (_step == _ForgotPasswordStep.verify)
                          _buildVerifyStep(theme),
                        if (_step == _ForgotPasswordStep.reset)
                          _buildResetStep(theme),
                        if (_step == _ForgotPasswordStep.done)
                          _buildSuccessStep(theme),
                      ],
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

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot your password?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Reset with a secure email link or OTP in a few secure steps.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textLight,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyStep(ThemeData theme) {
    final isRequesting = _activeAction == _ForgotPasswordAction.request;
    final isVerifying = _activeAction == _ForgotPasswordAction.verify;
    final isResending = _activeAction == _ForgotPasswordAction.resend;
    final canResend = _hasSentCode && _resendSecondsLeft == 0 && !_isBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Email'),
        const SizedBox(height: 10),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isBusy,
          decoration: InputDecoration(
            hintText: 'trishan@kaarya.com',
            errorText: _emailError,
          ),
          onChanged: (value) {
            if (_emailError != null) {
              setState(() {
                _emailError = _validateEmail(value);
              });
            }
          },
        ),
        const SizedBox(height: 12),
        Text(
          'We will email both a secure reset link and a verification code.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textLight,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        if (!_hasSentCode)
          MyButton(
            onPressed: _requestCode,
            text: isRequesting ? 'Sending code...' : 'Send code',
            isLoading: isRequesting,
          ),
        if (_hasSentCode) ...[
          if (canResend)
            TextButton(
              onPressed: () => _requestCode(isResend: true),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: AppColors.primary,
              ),
              child: Text(
                isResending ? 'Resending...' : 'Resend code',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            Text(
              'Resend available in ${_resendSecondsLeft}s',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
              ),
            ),
          if (_sendCodeInfo != null) ...[
            const SizedBox(height: 14),
            Text(
              _sendCodeInfo!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.45,
              ),
            ),
          ],
          if (_sendCodeError != null) ...[
            const SizedBox(height: 12),
            Text(
              _sendCodeError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildLabel('Verification Code'),
          const SizedBox(height: 10),
          PasswordResetOtpInputWidget(
            value: _otpValue,
            errorText: _otpError,
            enabled: !_isBusy,
            onChanged: (value) {
              setState(() {
                _otpValue = value;
                if (_otpError != null) {
                  _otpError = _validateOtp(value);
                }
              });
            },
          ),
          const SizedBox(height: 12),
          Text(
            _normalizedEmail.isNotEmpty
                ? 'Enter the 6-digit code sent to ${_maskEmail(_normalizedEmail)}.'
                : 'Enter the 6-digit code sent to your email.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          MyButton(
            onPressed: _verifyOtp,
            text: isVerifying ? 'Verifying...' : 'Verify code',
            isLoading: isVerifying,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _isBusy ? null : _useDifferentEmail,
              style: TextButton.styleFrom(foregroundColor: AppColors.textLight),
              child: const Text('Use different email'),
            ),
          ),
        ],
        const SizedBox(height: 18),
        TextButton(
          onPressed: _isBusy ? null : _returnToSignin,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.textLight,
          ),
          child: const Text('Back to sign in'),
        ),
      ],
    );
  }

  Widget _buildResetStep(ThemeData theme) {
    final isResetting = _activeAction == _ForgotPasswordAction.reset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('New Password'),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: true,
          enabled: !_isBusy,
          decoration: InputDecoration(errorText: _passwordError),
          onChanged: (value) {
            if (_passwordError != null) {
              setState(() {
                _passwordError = _validatePassword(value);
                if (_confirmPasswordController.text.isNotEmpty) {
                  _confirmPasswordError = _validateConfirmPassword(
                    value,
                    _confirmPasswordController.text,
                  );
                }
              });
            }
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Use 12+ characters with uppercase, lowercase, number, and symbol. This works for both OTP and secure link flows.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textLight,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel('Confirm Password'),
        const SizedBox(height: 10),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          enabled: !_isBusy,
          decoration: InputDecoration(errorText: _confirmPasswordError),
          onChanged: (value) {
            if (_confirmPasswordError != null) {
              setState(() {
                _confirmPasswordError = _validateConfirmPassword(
                  _passwordController.text,
                  value,
                );
              });
            }
          },
        ),
        if (_resetError != null) ...[
          const SizedBox(height: 12),
          Text(
            _resetError!,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: 24),
        MyButton(
          onPressed: _resetPassword,
          text: isResetting ? 'Resetting...' : 'Reset password',
          isLoading: isResetting,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _isBusy ? null : _backToVerification,
            child: const Text('Back to verification'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withAlpha(50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 18),
              Text(
                'Password updated successfully',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your account is now secure with the new password. Redirecting to sign in...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textLight,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        MyButton(
          onPressed: _returnToSignin,
          text: 'Continue to sign in',
          btnWidth: 170,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
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

class _ForgotPasswordStepper extends StatelessWidget {
  const _ForgotPasswordStepper({required this.step});

  final _ForgotPasswordStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeIndex = switch (step) {
      _ForgotPasswordStep.verify => 0,
      _ForgotPasswordStep.reset => 1,
      _ForgotPasswordStep.done => 2,
    };
    final progress = activeIndex == 0 ? 0.0 : activeIndex / 2;
    const labels = ['Verify', 'Reset', 'Done'];

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 16,
                    left: 26,
                    right: 26,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderStroke,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 26,
                    child: Container(
                      height: 4,
                      width: (constraints.maxWidth - 52) * progress,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      final isCompleted = index < activeIndex;
                      final isActive = index == activeIndex;

                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.primary : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive || isCompleted
                                ? AppColors.primary
                                : AppColors.borderStroke,
                            width: isActive ? 1.75 : 1,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(35),
                                    blurRadius: 0,
                                    spreadRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.textLight,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            final isHighlighted = index <= activeIndex;
            return SizedBox(
              width: 72,
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: index == activeIndex
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isHighlighted
                      ? AppColors.textDark
                      : AppColors.textLight,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
