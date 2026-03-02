import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/features/jobs/presentation/pages/apply_to_job_page.dart';
import 'package:kaarya/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobCardWidget extends StatelessWidget {
  const JobCardWidget({
    super.key,
    required this.job,
    this.onTap,
    this.onBookmark,
  });

  final JobEntity job;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        color: appSurfaceColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appSubtleBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 18 : 6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable body area — opens job detail
          InkWell(
            onTap:
                onTap ??
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        JobDetailPage(jobId: job.id, jobTitle: job.title),
                  ),
                ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Padding(
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
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              job.companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: appTextSecondaryColor(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final full = constraints.maxWidth;
                      final half = (full - 6) / 2;
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _chip(
                            context,
                            LucideIcons.mapPin,
                            job.location,
                            maxW: full,
                          ),
                          _chip(
                            context,
                            LucideIcons.clock,
                            job.employmentType,
                            maxW: half,
                          ),
                          _chip(
                            context,
                            LucideIcons.building2,
                            _formatWorkMode(job.workMode),
                            maxW: half,
                          ),
                          _chip(
                            context,
                            LucideIcons.banknote,
                            job.salaryRange,
                            maxW: full,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom action row — NOT inside the card's InkWell
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        if (job.hasApplied) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => JobDetailPage(
                                jobId: job.id,
                                jobTitle: job.title,
                              ),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ApplyToJobPage(
                                jobId: job.id,
                                jobTitle: job.title,
                                companyName: job.companyName,
                                companyLogo: job.companyLogo,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        job.hasApplied ? 'View Application' : 'Apply',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBookmark,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: appBorderColor(context)),
                      ),
                      child: Icon(
                        job.isSaved
                            ? LucideIcons.bookmarkCheck
                            : LucideIcons.bookmark,
                        color: job.isSaved
                            ? AppColors.primary
                            : AppColors.textLight,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge() {
    final label = _badgeLabel();
    final kind = _badgeKind();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeBg(kind),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _badgeText(kind),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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

  static Widget _chip(
    BuildContext context,
    IconData icon,
    String label, {
    required double maxW,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: appMutedSurfaceColor(context),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: appTextSecondaryColor(context)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: appTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _badgeLabel() {
    if (job.hasApplied) return 'Applied';
    if (job.status == 'draft') return 'Draft';
    if (job.status == 'closed') return 'Closed';
    if (_isClosingSoon(job.deadline)) return 'Closing Soon';
    return 'Suit You Best!';
  }

  String _badgeKind() {
    if (job.hasApplied) return 'applied';
    if (job.status == 'draft') return 'draft';
    if (job.status == 'closed') return 'closed';
    if (_isClosingSoon(job.deadline)) return 'urgent';
    return 'open';
  }

  Color _badgeBg(String kind) {
    switch (kind) {
      case 'applied':
        return AppColors.bgSecondary;
      case 'urgent':
        return const Color(0xFFFFF7ED);
      case 'draft':
        return const Color(0xFFF4F4F5);
      case 'closed':
        return const Color(0xFFFFF1F2);
      default:
        return const Color(0xFFECFDF3);
    }
  }

  Color _badgeText(String kind) {
    switch (kind) {
      case 'applied':
        return AppColors.primary;
      case 'urgent':
        return AppColors.warning;
      case 'draft':
        return AppColors.textDark;
      case 'closed':
        return AppColors.error;
      default:
        return const Color(0xFF059669);
    }
  }

  bool _isClosingSoon(String deadline) {
    final parsed = DateTime.tryParse(deadline);
    if (parsed == null) return false;
    final diff = parsed.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 3;
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
