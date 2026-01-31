import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kaarya/features/auth/presentation/widgets/profile_overview_card_widget.dart';
import 'package:kaarya/features/auth/presentation/widgets/update_profile_form_card_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
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

  @override
  void dispose() {
    fullNameController.dispose();
    emailAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .updateProfile(
            name: fullNameController.text.trim(),
            email: emailAddressController.text.trim(),
            photo: _selectedProfilePhoto,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == previous?.status) return;

      if (next.status == AuthStatus.updated) {
        SnackbarUtils.showSuccess(
          context,
          next.errorMessage ?? "Profile updated successfully!",
        );

        ref.read(authViewModelProvider.notifier).resetState();

        AppRoutes.pop(context);
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Failed to update profile, Please try again!",
        );

        ref.read(authViewModelProvider.notifier).resetState();
      }
    });

    final userSessionService = ref.watch(userSessionServiceProvider);
    final userName = userSessionService.getCurrentUserFullName() ?? 'User';
    final userEmail = userSessionService.getCurrentUserEmail() ?? '';
    final userProfilePicture =
        userSessionService.getCurrentUserProfilePicture() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
        child: Column(
          spacing: 18,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileOverviewCard(
              userName: userName,
              userEmail: userEmail,
              userProfilePicture: userProfilePicture,
            ),

            MyButton(
              text: "Generate Resume with AI",
              onPressed: () {},
              icon: Icon(LucideIcons.leafyGreen, color: Colors.white),
            ),

            UpdateProfileFormCard(
              formKey: formKey,
              fullNameController: fullNameController,
              emailAddressController: emailAddressController,
              profileImageUrl: userProfilePicture,
              onPhotoChanged: (photo) {
                setState(() {
                  _selectedProfilePhoto = photo;
                });
              },
            ),

            MyButton(
              text: "Save Changes",
              onPressed: _handleUpdateProfile,
              isLoading: authState.status == AuthStatus.loading,
            ),
          ],
        ),
      ),
    );
  }
}
