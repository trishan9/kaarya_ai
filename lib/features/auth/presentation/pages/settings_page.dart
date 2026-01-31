import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
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

  Future<void> _handleUpdateProfile() async {
    if (formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .updateProfile(
            name: fullNameController.text.trim(),
            email: emailAddressController.text.trim(),
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

    fullNameController.text = userName;
    emailAddressController.text = userEmail;

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
        child: Column(
          spacing: 18,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyButton(
              text: "Generate Resume with AI",
              onPressed: () {},
              icon: Icon(LucideIcons.leafyGreen, color: Colors.white),
            ),

            Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detail Information",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    SizedBox(height: 14),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Profile Picture",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(height: 6),

                              Text(
                                "Full Name",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(height: 6),

                              MyTextFormField(
                                controller: fullNameController,
                                text: "Trishan Wagle",
                                inputType: TextInputType.text,
                                validationErrorMessage: "Full name is required",
                              ),

                              SizedBox(height: 14),

                              Text(
                                "Email Address",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(height: 6),

                              MyTextFormField(
                                controller: emailAddressController,
                                text: "mailtotrishan@gmail.com",
                                inputType: TextInputType.emailAddress,
                                validationErrorMessage:
                                    "Email address is required",
                              ),

                              SizedBox(height: 14),

                              Text(
                                "Phone Number",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(height: 6),

                              MyTextFormField(
                                text: "9841XXXXXX",
                                inputType: TextInputType.text,
                                optional: true,
                              ),

                              SizedBox(height: 14),

                              Text(
                                "Full Address",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(height: 6),

                              MyTextFormField(
                                text:
                                    "Kathmandu-24, Dillibazar, Kathmandu, Nepal",
                                inputType: TextInputType.text,
                                optional: true,
                              ),

                              SizedBox(height: 14),

                              Text(
                                "Bio",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(height: 6),

                              MyTextFormField(
                                text: "Experienced Flutter Developer",
                                inputType: TextInputType.text,
                                optional: true,
                              ),

                              SizedBox(height: 14),

                              Text(
                                "Social Media",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(height: 6),

                              MyTextFormField(
                                text: "https://github.com/trishan9",
                                inputType: TextInputType.text,
                                optional: true,
                              ),

                              SizedBox(height: 14),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
