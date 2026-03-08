import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateProfileFormCard extends ConsumerStatefulWidget {
  const UpdateProfileFormCard({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailAddressController,
    required this.profileImageUrl,
    this.onPhotoChanged,
    this.headlineController,
    this.phoneController,
    this.locationController,
    this.summaryController,
    this.linkedinController,
    this.githubController,
    this.portfolioUrlController,
    this.isBasicProfile = false,
    this.embedInCard = true,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailAddressController;
  final String profileImageUrl;
  final ValueChanged<File?>? onPhotoChanged;
  final TextEditingController? headlineController;
  final TextEditingController? phoneController;
  final TextEditingController? locationController;
  final TextEditingController? summaryController;
  final TextEditingController? linkedinController;
  final TextEditingController? githubController;
  final TextEditingController? portfolioUrlController;

  final bool isBasicProfile;
  final bool embedInCard;

  @override
  ConsumerState<UpdateProfileFormCard> createState() =>
      _UpdateProfileFormCardState();
}

class _UpdateProfileFormCardState extends ConsumerState<UpdateProfileFormCard> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedMedia = [];

  File? get _selectedPhotoFile =>
      _selectedMedia.isNotEmpty ? File(_selectedMedia.first.path) : null;

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "This feature requires permission to access your camera or gallery. Please enable it in your device settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
      });
      widget.onPhotoChanged?.call(File(photo.path));
    }
  }

  Future<void> _pickFromGallery({bool allowMultiple = false}) async {
    try {
      if (allowMultiple) {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          imageQuality: 80,
        );

        if (images.isNotEmpty) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.addAll(images);
          });
          widget.onPhotoChanged?.call(File(images.first.path));
        }
      } else {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.add(image);
          });
          widget.onPhotoChanged?.call(File(image.path));
        }
      }
    } catch (e) {
      debugPrint('Gallery Error $e');

      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Unable to access gallery. Please try using the camera instead.',
        );
      }
    }
  }

  void _clearSelectedPhoto() {
    setState(() {
      _selectedMedia.clear();
    });
    widget.onPhotoChanged?.call(null);
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_outlined),
                title: Text('Open Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined),
                title: Text('Open Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isBasicProfile ? "Basic Information" : "Detail Information",
          style: Theme.of(context).textTheme.titleMedium,
        ),

        SizedBox(height: 14),

        Form(
          key: widget.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile Picture",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),

                  SizedBox(height: 6),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 520;
                      final hasLocalPhoto = _selectedPhotoFile != null;
                      final hasRemotePhoto = widget.profileImageUrl.isNotEmpty;
                      final hasPhoto = hasLocalPhoto || hasRemotePhoto;

                      if (!hasPhoto) {
                        return SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              _pickMedia();
                            },
                            child: Container(
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
                                  Icon(
                                    LucideIcons.cloudUpload,
                                    size: 28,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Drag and drop your file, or",
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey.shade700),
                                  ),
                                  Text(
                                    "choose here",
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Support: JPEG, JPG, PNG - max 5MB",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final imageWidget = SizedBox(
                        width: isCompact ? double.infinity : 160,
                        height: 120,
                        child: Stack(
                          children: [
                            _ProfileImagePreview(
                              localFile: _selectedPhotoFile,
                              imageUrl: hasLocalPhoto
                                  ? null
                                  : widget.profileImageUrl,
                            ),
                            if (hasLocalPhoto)
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: _DeleteAvatarButton(
                                  onPressed: _clearSelectedPhoto,
                                ),
                              ),
                          ],
                        ),
                      );

                      final uploadWidget = SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            _pickMedia();
                          },
                          child: Container(
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
                                Icon(
                                  LucideIcons.cloudUpload,
                                  size: 28,
                                  color: AppColors.primary,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Drag and drop your file, or",
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade700),
                                ),
                                Text(
                                  "choose here",
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Support: JPEG, JPG, PNG - max 5MB",
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      return Flex(
                        direction: isCompact ? Axis.vertical : Axis.horizontal,
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
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),

                  SizedBox(height: 6),

                  MyTextFormField(
                    controller: widget.fullNameController,
                    text: "Trishan Wagle",
                    inputType: TextInputType.text,
                    validationErrorMessage: "Full name is required",
                  ),

                  SizedBox(height: 14),

                  Text(
                    "Email Address",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),

                  SizedBox(height: 6),

                  MyTextFormField(
                    controller: widget.emailAddressController,
                    text: "mailtotrishan@gmail.com",
                    inputType: TextInputType.emailAddress,
                    validationErrorMessage: "Email address is required",
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return "Email address is required";
                      }
                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(trimmed)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),

                  if (!widget.isBasicProfile) ...[
                    SizedBox(height: 14),

                    Text(
                      "Headline",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(height: 6),

                    MyTextFormField(
                      controller: widget.headlineController,
                      text: "Product-minded Flutter Developer",
                      inputType: TextInputType.text,
                      optional: true,
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
                      controller: widget.phoneController,
                      text: "9841XXXXXX",
                      inputType: TextInputType.text,
                      optional: true,
                    ),

                    SizedBox(height: 14),

                    Text(
                      "Current Location",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(height: 6),

                    MyTextFormField(
                      controller: widget.locationController,
                      text: "Kathmandu, Nepal",
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
                      controller: widget.summaryController,
                      text: "Experienced Flutter Developer",
                      inputType: TextInputType.text,
                      optional: true,
                    ),

                    SizedBox(height: 14),

                    Text(
                      "LinkedIn URL",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(height: 6),

                    MyTextFormField(
                      controller: widget.linkedinController,
                      text: "https://linkedin.com/in/username",
                      inputType: TextInputType.url,
                      optional: true,
                    ),

                    SizedBox(height: 14),

                    Text(
                      "GitHub URL",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(height: 6),

                    MyTextFormField(
                      controller: widget.githubController,
                      text: "https://github.com/username",
                      inputType: TextInputType.url,
                      optional: true,
                    ),

                    SizedBox(height: 14),

                    Text(
                      "Portfolio URL",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(height: 6),

                    MyTextFormField(
                      controller: widget.portfolioUrlController,
                      text: "https://yourportfolio.com",
                      inputType: TextInputType.text,
                      optional: true,
                    ),

                    SizedBox(height: 14),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.all(widget.embedInCard ? 16.0 : 0),
      child: _buildContent(context),
    );
    if (!widget.embedInCard) return content;
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: content,
    );
  }
}

class _ProfileImagePreview extends StatelessWidget {
  const _ProfileImagePreview({this.localFile, this.imageUrl});

  final File? localFile;
  final String? imageUrl;

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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: localFile != null
            ? Image.file(localFile!, fit: BoxFit.cover)
            : (imageUrl == null || imageUrl!.isEmpty)
            ? SizedBox.shrink()
            : Image.network(
                imageUrl!,
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
            color: Colors.black.withValues(alpha: 0.08),
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
