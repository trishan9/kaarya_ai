import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/job_card_widget.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/notifications_widget.dart';
import 'package:kaarya/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:kaarya/features/bookmarks/presentation/view_model/bookmark_view_model.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SavedPage extends ConsumerStatefulWidget {
  const SavedPage({super.key});

  @override
  ConsumerState<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends ConsumerState<SavedPage> {
  int _typeTab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(bookmarkViewModelProvider.notifier).loadBookmarks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookmarkViewModelProvider);
    final data = state.bookmarks;
    final isLoading = state.isLoading;
    final error = state.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: NotificationsWidget(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(bookmarkViewModelProvider.notifier).loadBookmarks(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _buildHero(data),
            const SizedBox(height: 16),
            _buildTypeTabs(data),
            const SizedBox(height: 14),
            if (isLoading && data == null)
              const SizedBox(height: 200, child: LoaderWidget())
            else if (error != null && data == null)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      error,
                      style: const TextStyle(color: AppColors.textMedium),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(bookmarkViewModelProvider.notifier)
                          .loadBookmarks(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              ..._buildContent(data),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BookmarksListEntity? data) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your saved opportunities, neatly organized.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Switch between Jobs and Interviews, filter what matters, and jump back in whenever you are ready.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _statBox('Total Saved', '${data?.totalSaved ?? 0}'),
                    const SizedBox(width: 8),
                    _statBox('Bookmarked Jobs', '${data?.bookmarkedJobs ?? 0}'),
                    const SizedBox(width: 8),
                    _statBox(
                      'Saved Interviews',
                      '${data?.savedInterviews ?? 0}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTabs(BookmarksListEntity? data) {
    return Row(
      children: [
        _typeChip('Jobs (${data?.bookmarkedJobs ?? 0})', 0),
        const SizedBox(width: 8),
        _typeChip('Interviews (${data?.savedInterviews ?? 0})', 1),
      ],
    );
  }

  Widget _typeChip(String label, int index) {
    final selected = _typeTab == index;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: selected ? Colors.white : AppColors.textDark,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(
        color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
      ),
      onSelected: (_) => setState(() => _typeTab = index),
    );
  }

  List<Widget> _buildContent(BookmarksListEntity? data) {
    if (data == null) return [];
    if (_typeTab == 0) {
      if (data.jobs.isEmpty) {
        return [
          _emptyState(
            LucideIcons.bookmark,
            'No saved jobs yet',
            'Jobs you bookmark will appear here.\nStart exploring to find your next opportunity!',
          ),
        ];
      }
      return data.jobs
          .map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobCardWidget(
                job: job,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        JobDetailPage(jobId: job.id, jobTitle: job.title),
                  ),
                ),
                onBookmark: () async {
                  final vm = ref.read(bookmarkViewModelProvider.notifier);
                  if (job.isSaved) {
                    await vm.unsaveJobBookmark(job.id);
                  } else {
                    await vm.saveJobBookmark(job.id);
                  }
                  await vm.loadBookmarks();
                },
              ),
            ),
          )
          .toList();
    } else {
      if (data.interviews.isEmpty) {
        return [
          _emptyState(
            LucideIcons.mic,
            'No saved interviews yet',
            'Interviews you save will appear here.\nHead to AI Interview Hub to discover mock interviews!',
          ),
        ];
      }
      return data.interviews
          .map(
            (interview) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _interviewCard(interview),
            ),
          )
          .toList();
    }
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.bgSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _interviewCard(InterviewEntity interview) {
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
          InkWell(
            onTap: () {},
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: interview.hasAttempted
                              ? AppColors.bgLightGreen
                              : AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          interview.hasAttempted ? 'Completed' : 'Not Started',
                          style: TextStyle(
                            color: interview.hasAttempted
                                ? AppColors.success2
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _typeLabel(interview.interviewType),
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
                      _companyAvatar(interview),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              interview.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              interview.companyName,
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
                      _chip(LucideIcons.mic, 'Mock Interview'),
                      _chip(LucideIcons.building2, interview.companyName),
                      if (interview.hasAttempted &&
                          interview.myLatestScore != null)
                        _chip(
                          LucideIcons.trophy,
                          'Score: ${interview.myLatestScore!.toStringAsFixed(0)}%',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: interview.hasAttempted
                        ? OutlinedButton(
                            onPressed: () {},
                            child: const Text(
                              'Review Results',
                              style: TextStyle(fontSize: 13),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {},
                            child: const Text(
                              'Take Interview',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final vm = ref.read(bookmarkViewModelProvider.notifier);
                      if (interview.isSaved) {
                        await vm.unsaveInterviewBookmark(interview.id);
                      } else {
                        await vm.saveInterviewBookmark(interview.id);
                      }
                      await vm.loadBookmarks();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Icon(
                        interview.isSaved
                            ? LucideIcons.bookmarkCheck
                            : LucideIcons.bookmark,
                        color: interview.isSaved
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

  Widget _companyAvatar(InterviewEntity interview) {
    final logo = interview.companyLogo;
    if (logo != null && logo.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          logo,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(interview.companyName),
        ),
      );
    }
    return _fallbackAvatar(interview.companyName);
  }

  Widget _fallbackAvatar(String name) {
    final initial = name.isEmpty ? 'C' : name[0].toUpperCase();
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }

  static Widget _chip(IconData icon, String label) {
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

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'technical':
        return 'Technical';
      case 'behavioral':
        return 'Behavioral';
      case 'system_design':
        return 'System Design';
      default:
        return type;
    }
  }
}
