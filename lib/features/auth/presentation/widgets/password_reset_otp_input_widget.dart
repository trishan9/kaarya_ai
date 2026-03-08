import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';

class PasswordResetOtpInputWidget extends StatefulWidget {
  const PasswordResetOtpInputWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  State<PasswordResetOtpInputWidget> createState() =>
      _PasswordResetOtpInputWidgetState();
}

class _PasswordResetOtpInputWidgetState
    extends State<PasswordResetOtpInputWidget> {
  static const int _otpLength = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _syncControllers(widget.value);
  }

  @override
  void didUpdateWidget(covariant PasswordResetOtpInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _syncControllers(widget.value);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _sanitize(String value) {
    final numbersOnly = value.replaceAll(RegExp(r'\D'), '');
    return numbersOnly.length <= _otpLength
        ? numbersOnly
        : numbersOnly.substring(0, _otpLength);
  }

  void _syncControllers(String value) {
    final digits = _sanitize(value);
    for (var index = 0; index < _otpLength; index++) {
      final next = index < digits.length ? digits[index] : '';
      if (_controllers[index].text != next) {
        _controllers[index].text = next;
      }
    }
  }

  void _setFocus(int index) {
    final bounded = math.max(0, math.min(index, _otpLength - 1));
    final node = _focusNodes[bounded];
    if (!node.hasFocus) {
      node.requestFocus();
    }
    _controllers[bounded].selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controllers[bounded].text.length,
    );
  }

  void _updateValue(List<String> slots) {
    widget.onChanged(slots.join());
  }

  void _applyDigits(int startIndex, String rawValue) {
    final digits = _sanitize(rawValue);
    if (digits.isEmpty) {
      return;
    }

    final slots = List<String>.generate(
      _otpLength,
      (index) => _controllers[index].text,
    );
    var cursor = startIndex;
    for (final digit in digits.split('')) {
      if (cursor >= _otpLength) {
        break;
      }
      slots[cursor] = digit;
      cursor += 1;
    }

    _updateValue(slots);
    _setFocus(cursor >= _otpLength ? _otpLength - 1 : cursor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = ((constraints.maxWidth - 50) / _otpLength).clamp(
              40.0,
              52.0,
            );

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_otpLength * 2 - 1, (visualIndex) {
                if (visualIndex.isOdd) {
                  return Text(
                    '-',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
                  );
                }

                final index = visualIndex ~/ 2;
                return SizedBox(
                  width: boxWidth,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: widget.enabled,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: _otpLength,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      errorText: null,
                      filled: true,
                      fillColor: widget.enabled
                          ? Colors.white
                          : AppColors.bgTertiary,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: widget.errorText == null
                              ? AppColors.borderStroke
                              : AppColors.error,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.borderStroke,
                        ),
                      ),
                    ),
                    onTap: () => _setFocus(index),
                    onChanged: (value) {
                      final sanitized = _sanitize(value);
                      if (sanitized.isEmpty) {
                        final slots = List<String>.generate(
                          _otpLength,
                          (slotIndex) => _controllers[slotIndex].text,
                        );
                        slots[index] = '';
                        _updateValue(slots);
                        return;
                      }

                      if (sanitized.length == 1) {
                        final slots = List<String>.generate(
                          _otpLength,
                          (slotIndex) => _controllers[slotIndex].text,
                        );
                        slots[index] = sanitized;
                        _updateValue(slots);
                        if (index < _otpLength - 1) {
                          _setFocus(index + 1);
                        }
                        return;
                      }

                      _applyDigits(index, sanitized);
                    },
                    onSubmitted: (_) {
                      if (index < _otpLength - 1) {
                        _setFocus(index + 1);
                      }
                    },
                    onEditingComplete: () {},
                  ),
                );
              }),
            );
          },
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
