import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kaarya/features/auth/data/services/candidate_profile_service.dart';
import 'package:kaarya/features/auth/presentation/widgets/candidate_profile_form_card_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/change_password_form_card_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/biometric_login_form_card_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/profile_overview_card_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/update_profile_form_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/pages/resume_builder_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _SettingsTab { profile, security }

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  _SettingsTab _selectedTab = _SettingsTab.profile;
  final formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  File? _selectedProfilePhoto;
  bool _didPrefill = false;

  @override
  void initState() {
    super.initState();
    _prefillUserDetails();
  }

  void _prefillUserDetails() {
    if (_didPrefill) return;
    final userSessionService = ref.read(userSessionServiceProvider);
    fullNameController.text =
        userSessionService.getCurrentUserFullName() ?? 'User';
    emailAddressController.text =
        userSessionService.getCurrentUserEmail() ?? '';
    _didPrefill = true;
  }

  void _prefillFromApi(CurrentUserData user) {
    if ((user.name ?? '').trim().isNotEmpty &&
        fullNameController.text.trim() != user.name!.trim()) {
      fullNameController.text = user.name!.trim();
    }
    if ((user.email ?? '').trim().isNotEmpty &&
        emailAddressController.text.trim() != user.email!.trim()) {
      emailAddressController.text = user.email!.trim();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile(
    Map<String, dynamic>? candidateProfile, {
    bool skipFormValidation = false,
  }) async {
    final form = formKey.currentState;
    if (!skipFormValidation && (form == null || !form.validate())) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Check the highlighted required fields first.',
        );
      }
      return;
    }
    await ref
        .read(authViewModelProvider.notifier)
        .updateProfile(
          name: fullNameController.text.trim(),
          email: emailAddressController.text.trim(),
          photo: _selectedProfilePhoto,
          candidateProfile: candidateProfile,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authMeResponseProvider);
    final profileAsync = ref.watch(candidateProfileProvider);
    final authState = ref.watch(authViewModelProvider);
    final isRecruiter = ref.watch(isRecruiterProvider);
    final isCollege = ref.watch(isCollegeProvider);
    final isCandidate = !isRecruiter && !isCollege;
    final userSessionService = ref.watch(userSessionServiceProvider);
    final provider = userSessionService.getCurrentUserProvider();
    final hasEmailCredentials = provider?.toLowerCase() == 'email';
    final currentUserAsync = ref.watch(currentUserProvider);

    // Prefill name/email from API when available (overrides session fallback)
    ref.listen(currentUserProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        _prefillFromApi(next.value!);
      }
    });

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == previous?.status) return;

      if (next.status == AuthStatus.updated) {
        SnackbarUtils.showSuccess(
          context,
          next.errorMessage ?? 'Profile updated successfully!',
        );
        ref.invalidate(authMeResponseProvider);
        ref.read(authViewModelProvider.notifier).resetState();
      } else if (next.status == AuthStatus.passwordChanged) {
        SnackbarUtils.showSuccess(context, 'Password changed successfully.');
        ref.read(authViewModelProvider.notifier).resetState();
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Something went wrong. Please try again.',
        );
        ref.read(authViewModelProvider.notifier).resetState();
      }
    });

    final apiUser = currentUserAsync.asData?.value;
    final userName =
        apiUser?.name ?? userSessionService.getCurrentUserFullName() ?? 'User';
    final userEmail =
        apiUser?.email ?? userSessionService.getCurrentUserEmail() ?? '';
    final userProfilePicture =
        apiUser?.photo ??
        userSessionService.getCurrentUserProfilePicture() ??
        '';

    final pagePadding = MediaQuery.of(context).size.width < 700
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
        : const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabSwitcher(),
            const SizedBox(height: 18),
            if (_selectedTab == _SettingsTab.profile) ...[
              ProfileOverviewCard(
                userName: userName,
                userEmail: userEmail,
                userProfilePicture: userProfilePicture,
              ),
              if (isCandidate) ...[
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return MyButton(
                      text: 'Generate Resume with AI',
                      btnWidth: constraints.maxWidth < 700
                          ? double.infinity
                          : 280,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResumeBuilderScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        LucideIcons.leafyGreen,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                profileAsync.when(
                  data: (profile) => CandidateProfileFormCard(
                    key: ValueKey(
                      'candidate-${profile.hashCode}-${apiUser?.name ?? ''}-${apiUser?.email ?? ''}-$userProfilePicture',
                    ),
                    formKey: formKey,
                    fullNameController: fullNameController,
                    emailAddressController: emailAddressController,
                    profileImageUrl: userProfilePicture,
                    initialProfile: profile,
                    onPhotoChanged: (photo) {
                      setState(() => _selectedProfilePhoto = photo);
                    },
                    onSave: (candidateProfile) => _handleUpdateProfile(
                      candidateProfile,
                      skipFormValidation: true,
                    ),
                    isSaving: authState.status == AuthStatus.loading,
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => CandidateProfileFormCard(
                    key: const ValueKey('candidate-empty-profile'),
                    formKey: formKey,
                    fullNameController: fullNameController,
                    emailAddressController: emailAddressController,
                    profileImageUrl: userProfilePicture,
                    initialProfile: null,
                    onPhotoChanged: (photo) {
                      setState(() => _selectedProfilePhoto = photo);
                    },
                    onSave: (candidateProfile) => _handleUpdateProfile(
                      candidateProfile,
                      skipFormValidation: true,
                    ),
                    isSaving: authState.status == AuthStatus.loading,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 18),
                UpdateProfileFormCard(
                  formKey: formKey,
                  fullNameController: fullNameController,
                  emailAddressController: emailAddressController,
                  profileImageUrl: userProfilePicture,
                  onPhotoChanged: (photo) {
                    setState(() => _selectedProfilePhoto = photo);
                  },
                  isBasicProfile: true,
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return MyButton(
                      text: 'Save Changes',
                      btnWidth: constraints.maxWidth < 700
                          ? double.infinity
                          : 220,
                      onPressed: () => _handleUpdateProfile(null),
                      isLoading: authState.status == AuthStatus.loading,
                    );
                  },
                ),
              ],
            ] else ...[
              if (hasEmailCredentials) ...[
                const ChangePasswordFormCard(),
                const SizedBox(height: 18),
                const BiometricLoginFormCard(),
              ] else
                _buildNoPasswordMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          _SettingsTabOption(
            label: 'Profile',
            icon: LucideIcons.userRound,
            selected: _selectedTab == _SettingsTab.profile,
            onTap: () => setState(() => _selectedTab = _SettingsTab.profile),
          ),
          _SettingsTabOption(
            label: 'Security',
            icon: LucideIcons.shieldCheck,
            selected: _selectedTab == _SettingsTab.security,
            onTap: () => setState(() => _selectedTab = _SettingsTab.security),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPasswordMessage() {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.shieldCheck,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Password login is not enabled for this account. You signed in with a social provider (e.g. Google, GitHub).',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTabOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SettingsTabOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
