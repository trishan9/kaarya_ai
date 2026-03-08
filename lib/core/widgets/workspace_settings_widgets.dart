import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WorkspaceSettingsSection extends StatelessWidget {
  const WorkspaceSettingsSection({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.0 : 0.03,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _textSecondary(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class WorkspaceSettingsField extends StatelessWidget {
  const WorkspaceSettingsField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.validator,
    this.helperText,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final String? helperText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: _textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: _inputDecoration(context, hintText: hintText),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            helperText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _textSecondary(context)),
          ),
        ],
      ],
    );
  }
}

class WorkspaceLogoPicker extends StatelessWidget {
  const WorkspaceLogoPicker({
    super.key,
    required this.label,
    required this.workspaceName,
    this.remoteLogoUrl,
    this.localLogoFile,
    required this.onUploadTap,
    required this.onResetTap,
    this.errorText,
  });

  final String label;
  final String workspaceName;
  final String? remoteLogoUrl;
  final File? localLogoFile;
  final VoidCallback onUploadTap;
  final VoidCallback onResetTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        localLogoFile != null ||
        (remoteLogoUrl != null && remoteLogoUrl!.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: _textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surfaceMutedColor(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor(context)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;
              return Flex(
                direction: isCompact ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WorkspaceLogoPreview(
                    workspaceName: workspaceName,
                    remoteLogoUrl: remoteLogoUrl,
                    localLogoFile: localLogoFile,
                  ),
                  SizedBox(
                    width: isCompact ? 0 : 14,
                    height: isCompact ? 14 : 0,
                  ),
                  if (isCompact)
                    SizedBox(
                      width: double.infinity,
                      child: _LogoActions(
                        hasImage: hasImage,
                        onUploadTap: onUploadTap,
                        onResetTap: onResetTap,
                      ),
                    )
                  else
                    Expanded(
                      child: _LogoActions(
                        hasImage: hasImage,
                        onUploadTap: onUploadTap,
                        onResetTap: onResetTap,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class WorkspaceInviteCodePanel extends StatelessWidget {
  const WorkspaceInviteCodePanel({
    super.key,
    required this.code,
    required this.onCopyCode,
    required this.onCopyLink,
    required this.onResetCode,
    this.isBusy = false,
  });

  final String code;
  final VoidCallback onCopyCode;
  final VoidCallback onCopyLink;
  final VoidCallback onResetCode;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceMutedColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _borderColor(context),
          style: BorderStyle.solid,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          return Flex(
            direction: isCompact ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INVITE CODE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _textSecondary(context),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    code.isEmpty ? 'Unavailable' : code,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _textPrimary(context),
                    ),
                  ),
                ],
              ),
              SizedBox(width: isCompact ? 0 : 12, height: isCompact ? 12 : 0),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InviteActionButton(
                    icon: LucideIcons.copy,
                    onPressed: onCopyCode,
                  ),
                  _InviteActionButton(
                    icon: LucideIcons.link2,
                    onPressed: onCopyLink,
                  ),
                  _InviteActionButton(
                    icon: LucideIcons.rotateCcw,
                    onPressed: isBusy ? null : onResetCode,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class WorkspaceMemberTile extends StatelessWidget {
  const WorkspaceMemberTile({
    super.key,
    required this.name,
    required this.email,
    required this.badgeLabel,
    this.photoUrl,
    this.onRemove,
    this.removeEnabled = true,
  });

  final String name;
  final String email;
  final String badgeLabel;
  final String? photoUrl;
  final VoidCallback? onRemove;
  final bool removeEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceMutedColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor(context)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          final leading = Row(
            children: [
              _WorkspaceAvatar(name: name, photoUrl: photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  border: Border.all(
                    color: _isDark(context)
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onRemove != null)
                OutlinedButton.icon(
                  onPressed: removeEnabled ? onRemove : null,
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [leading, const SizedBox(height: 12), actions],
            );
          }

          return Row(
            children: [
              Expanded(child: leading),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class WorkspaceMetricTile extends StatelessWidget {
  const WorkspaceMetricTile({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceMutedColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: _textSecondary(context)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _textPrimary(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkspaceEmptyState extends StatelessWidget {
  const WorkspaceEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: _textSecondary(context)),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _textSecondary(context),
                  height: 1.45,
                ),
              ),
              if (action != null) ...[const SizedBox(height: 18), action!],
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(BuildContext context, {String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: _surfaceColor(context),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _borderColor(context)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _borderColor(context)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
  );
}

class _WorkspaceLogoPreview extends StatelessWidget {
  const _WorkspaceLogoPreview({
    required this.workspaceName,
    this.remoteLogoUrl,
    this.localLogoFile,
  });

  final String workspaceName;
  final String? remoteLogoUrl;
  final File? localLogoFile;

  @override
  Widget build(BuildContext context) {
    final initials = workspaceName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    ImageProvider<Object>? imageProvider;
    if (localLogoFile != null) {
      imageProvider = FileImage(localLogoFile!);
    } else if (remoteLogoUrl != null && remoteLogoUrl!.trim().isNotEmpty) {
      imageProvider = NetworkImage(remoteLogoUrl!);
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.primary.withValues(alpha: 0.1),
        image: imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: imageProvider == null
          ? Text(
              initials.isEmpty ? 'W' : initials,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}

class _LogoActions extends StatelessWidget {
  const _LogoActions({
    required this.hasImage,
    required this.onUploadTap,
    required this.onResetTap,
  });

  final bool hasImage;
  final VoidCallback onUploadTap;
  final VoidCallback onResetTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: onUploadTap,
              icon: const Icon(LucideIcons.upload, size: 16),
              label: const Text('Upload Logo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textDark,
                side: BorderSide(color: _borderColor(context)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (hasImage)
              TextButton(
                onPressed: onResetTap,
                style: TextButton.styleFrom(
                  foregroundColor: _textSecondary(context),
                  textStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                child: const Text('Reset'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'PNG, JPG, or WebP up to 5MB.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textLight),
        ),
      ],
    );
  }
}

class _WorkspaceAvatar extends StatelessWidget {
  const _WorkspaceAvatar({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgSecondary,
        image: photoUrl != null && photoUrl!.trim().isNotEmpty
            ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: photoUrl != null && photoUrl!.trim().isNotEmpty
          ? null
          : Text(
              initials.isEmpty ? 'U' : initials,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

class _InviteActionButton extends StatelessWidget {
  const _InviteActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: _borderColor(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(icon, size: 18, color: _textPrimary(context)),
      ),
    );
  }
}

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _surfaceColor(BuildContext context) =>
    _isDark(context) ? const Color(0xFF0F141B) : Colors.white;

Color _surfaceMutedColor(BuildContext context) =>
    _isDark(context) ? const Color(0xFF111922) : AppColors.bgTertiary;

Color _borderColor(BuildContext context) =>
    _isDark(context) ? const Color(0xFF263446) : AppColors.borderStroke;

Color _textPrimary(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface;

Color _textSecondary(BuildContext context) =>
    _isDark(context) ? const Color(0xFF8DA1B5) : AppColors.textLight;
