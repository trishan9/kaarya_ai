import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';

class OverlappingAvatars extends StatelessWidget {
  const OverlappingAvatars({
    super.key,
    required this.avatars,
    this.extraCount = 0,
  });

  final List<String> avatars;
  final int extraCount;

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 28;
    const double overlap = 20;

    final double width = (avatars.length * overlap) + avatarSize;

    return SizedBox(
      height: avatarSize,
      width: width,
      child: Stack(
        children: [
          for (int i = 0; i < avatars.length; i++)
            Positioned(
              left: i * overlap,
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(avatars[i]),
              ),
            ),

          Positioned(
            left: avatars.length * overlap,
            child: CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: AppColors.bgSecondary,
              child: Text(
                '+$extraCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
