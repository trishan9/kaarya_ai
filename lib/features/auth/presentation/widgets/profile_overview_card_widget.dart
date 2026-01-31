import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileOverviewCard extends StatelessWidget {
  const ProfileOverviewCard({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userProfilePicture,
  });

  final String userName;
  final String userEmail;
  final String userProfilePicture;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Overview",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 520;
                return Flex(
                  direction: isCompact ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isCompact ? 0 : 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Flutter Engineer | AI Resume Builder",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade700),
                          ),

                          SizedBox(height: 12),

                          Text(
                            "Detail-focused engineer who loves building delightful mobile experiences with clean architecture and AI-assisted workflows.",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),

                          SizedBox(height: 14),

                          Row(
                            children: [
                              Icon(
                                LucideIcons.mail,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  userEmail,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Kathmandu, Nepal",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: isCompact ? 0 : 16,
                      height: isCompact ? 16 : 0,
                    ),

                    SizedBox(
                      width: isCompact ? double.infinity : 150,
                      height: isCompact ? 300 : 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: userProfilePicture.isNotEmpty
                            ? Image.network(
                                userProfilePicture,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _ProfileImageFallback();
                                },
                              )
                            : _ProfileImageFallback(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileImageFallback extends StatelessWidget {
  const _ProfileImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(LucideIcons.user, size: 42, color: Colors.grey.shade500),
      ),
    );
  }
}
