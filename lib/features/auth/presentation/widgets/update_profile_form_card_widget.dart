import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UpdateProfileFormCard extends StatelessWidget {
  const UpdateProfileFormCard({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailAddressController,
    required this.profileImageUrl,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailAddressController;
  final String profileImageUrl;

  @override
  Widget build(BuildContext context) {
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

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 520;
                          final hasPhoto = profileImageUrl.isNotEmpty;

                          if (!hasPhoto) {
                            return SizedBox(
                              height: 120,
                              width: double.infinity,
                              child: _UploadPanel(),
                            );
                          }

                          final imageWidget = SizedBox(
                            width: isCompact ? double.infinity : 160,
                            height: 120,
                            child: Stack(
                              children: [
                                _ProfileImagePreview(imageUrl: profileImageUrl),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: _DeleteAvatarButton(onPressed: () {}),
                                ),
                              ],
                            ),
                          );

                          final uploadWidget = SizedBox(
                            height: 120,
                            width: double.infinity,
                            child: _UploadPanel(),
                          );

                          return Flex(
                            direction: isCompact
                                ? Axis.vertical
                                : Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              imageWidget,
                              SizedBox(
                                width: isCompact ? 0 : 14,
                                height: isCompact ? 12 : 0,
                              ),
                              if (isCompact)
                                uploadWidget
                              else
                                Expanded(child: uploadWidget),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 14),

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
                        validationErrorMessage: "Email address is required",
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
                        text: "Kathmandu-24, Dillibazar, Kathmandu, Nepal",
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
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.cloudUpload, size: 28, color: AppColors.primary),
          SizedBox(height: 8),
          Text(
            "Drag and drop your file, or",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
          ),
          Text(
            "choose here",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Support: JPEG, JPG, PNG - max 5MB",
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileImagePreview extends StatelessWidget {
  const _ProfileImagePreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DeleteAvatarButton extends StatelessWidget {
  const _DeleteAvatarButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.delete_outline, size: 18),
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        splashRadius: 18,
      ),
    );
  }
}
