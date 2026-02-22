import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Job card for recruiter views - shows Manage Job instead of Apply.
class RecruiterJobCardWidget extends StatelessWidget {
  const RecruiterJobCardWidget({
    super.key,
    required this.job,
    this.onManageTap,
  });

  final JobEntity job;
  final VoidCallback? onManageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _badge(),
                    const Spacer(),
                    Text(
                      _relativeTime(job.createdAt),
                      style: const TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _companyAvatar(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip(LucideIcons.mapPin, job.location),
                    _chip(LucideIcons.clock, job.employmentType),
                    _chip(LucideIcons.building2, _formatWorkMode(job.workMode)),
                    _chip(LucideIcons.banknote, job.salaryRange),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${job.applicationsCount} applicants · ${job.viewsCount} views',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onManageTap,
                child: const Text('Manage Job'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge() {
    final label = _badgeLabel();
    final color = _badgeColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _badgeLabel() {
    if (job.status == 'draft') return 'Draft';
    if (job.status == 'closed') return 'Closed';
    if (_isClosingSoon(job.deadline)) return 'Closing Soon';
    return 'Open Hiring';
  }

  Color _badgeColor() {
    if (job.status == 'draft') return AppColors.textMedium;
    if (job.status == 'closed') return AppColors.error;
    if (_isClosingSoon(job.deadline)) return AppColors.warning;
    return const Color(0xFF059669);
  }

  Widget _companyAvatar() {
    final logo = job.companyLogo;
    if (logo != null && logo.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          logo,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(),
        ),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    final initial = job.companyName.isEmpty ? 'K' : job.companyName[0];
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        initial.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textLight),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isClosingSoon(String deadline) {
    final parsed = DateTime.tryParse(deadline);
    if (parsed == null) return false;
    final diff = parsed.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 14;
  }

  String _relativeTime(String createdAt) {
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return 'just now';
    final diff = DateTime.now().difference(parsed);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo ago';
    return '${(months / 12).floor()}y ago';
  }

  String _formatWorkMode(String workMode) {
    if (workMode.trim().isEmpty) return 'Onsite';
    return workMode
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join('-');
  }
}
