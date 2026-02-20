import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/notifications_widget.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_section_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_session_entity.dart';
import 'package:kaarya/features/interviews/domain/usecases/list_my_sessions_usecase.dart';
import 'package:kaarya/features/interviews/presentation/pages/interview_detail_page.dart';
import 'package:kaarya/features/interviews/presentation/pages/interview_feedback_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── Sort ─────────────────────────────────────────────────────────────────────

enum _SortValue {
  recentlyCreated,
  scoreHighToLow,
  mostAttempted,
  titleAsc,
  companyAsc,
}

extension _SortValueLabel on _SortValue {
  String get label {
    switch (this) {
      case _SortValue.recentlyCreated:
        return 'Recently created';
      case _SortValue.scoreHighToLow:
        return 'Score: High to low';
      case _SortValue.mostAttempted:
        return 'Most attempts';
      case _SortValue.titleAsc:
        return 'Title: A–Z';
      case _SortValue.companyAsc:
        return 'Company: A–Z';
    }
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class MyInterviewsPage extends ConsumerStatefulWidget {
  const MyInterviewsPage({super.key});

  @override
  ConsumerState<MyInterviewsPage> createState() => _MyInterviewsPageState();
}

class _MyInterviewsPageState extends ConsumerState<MyInterviewsPage> {
  int _tabIndex = 0; // 0 = Taken, 1 = Created
  _SortValue _sort = _SortValue.recentlyCreated;
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardViewModelProvider.notifier).loadInterviews(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref
        .read(dashboardViewModelProvider.notifier)
        .loadInterviews(forceRefresh: true);
  }

  List<InterviewEntity> _getList(InterviewsSectionEntity? data) {
    if (data == null) return const [];
    return _tabIndex == 0 ? data.takenByMe : data.createdByMe;
  }

  List<InterviewEntity> _filtered(List<InterviewEntity> list) {
    var result = [...list];
    if (_search.trim().isNotEmpty) {
      final q = _search.trim().toLowerCase();
      result = result.where((i) {
        return i.title.toLowerCase().contains(q) ||
            i.companyName.toLowerCase().contains(q) ||
            i.interviewType.toLowerCase().contains(q);
      }).toList();
    }
    switch (_sort) {
      case _SortValue.recentlyCreated:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortValue.scoreHighToLow:
        result.sort(
          (a, b) => (b.myLatestScore ?? double.negativeInfinity)
              .compareTo(a.myLatestScore ?? double.negativeInfinity),
        );
      case _SortValue.mostAttempted:
        result.sort((a, b) => b.attemptsCount.compareTo(a.attemptsCount));
      case _SortValue.titleAsc:
        result.sort((a, b) => a.title.compareTo(b.title));
      case _SortValue.companyAsc:
        result.sort((a, b) => a.companyName.compareTo(b.companyName));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final data = state.interviewsData;
    final isLoading =
        state.interviewsStatus == DashboardLoadStatus.loading && data == null;
    final isError =
        state.interviewsStatus == DashboardLoadStatus.error && data == null;

    final list = _filtered(_getList(data));
    final takenCount = data?.takenByMe.length ?? 0;
    final createdCount = data?.createdByMe.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Interviews',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => AppRoutes.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: NotificationsWidget(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _HeroBanner(data: data),
            const SizedBox(height: 14),
            // Tab bar
            _TabRow(
              selected: _tabIndex,
              takenCount: takenCount,
              createdCount: createdCount,
              onSelected: (i) => setState(() {
                _tabIndex = i;
                _search = '';
                _searchCtrl.clear();
              }),
            ),
            const SizedBox(height: 10),
            // Toolbar: Search + Sort
            _Toolbar(
              searchCtrl: _searchCtrl,
              sortValue: _sort,
              onSearchChanged: (v) => setState(() => _search = v),
              onSortChanged: (v) => setState(() => _sort = v),
            ),
            const SizedBox(height: 10),
            // Content
            if (isLoading)
              const SizedBox(height: 260, child: LoaderWidget())
            else if (isError)
              _ErrorBlock(
                message:
                    state.interviewsErrorMessage ?? 'Failed to load interviews',
                onRetry: _refresh,
              )
            else if (list.isEmpty)
              _EmptyState(
                isSearch: _search.trim().isNotEmpty,
                tabLabel: _tabIndex == 0 ? 'taken' : 'created',
              )
            else
              ...list.map(
                (interview) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InterviewCard(
                    interview: interview,
                    onTap: () => _showDetail(context, interview),
                    onTake: () => AppRoutes.push(
                      context,
                      InterviewDetailPage(interview: interview),
                    ),
                    onViewResults: interview.hasAttempted &&
                            interview.myLatestSessionId != null
                        ? () => AppRoutes.push(
                              context,
                              InterviewFeedbackPage(
                                sessionId: interview.myLatestSessionId!,
                                interviewId: interview.id,
                                immediate: true,
                              ),
                            )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, InterviewEntity interview) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(interview: interview),
    );
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final InterviewsSectionEntity? data;
  const _HeroBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final takenCount = data?.takenByMe.length ?? 0;
    final createdCount = data?.createdByMe.length ?? 0;
    final avgScore = data?.averageScore ?? 0.0;
    final totalAttempts = data?.takenByMe
            .fold<int>(0, (sum, i) => sum + i.attemptsCount) ??
        0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
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
                Row(
                  children: [
                    const Icon(LucideIcons.calendarCheck,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'My Interview History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your mock interviews and review past performances.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatBox(
                      icon: LucideIcons.clipboardCheck,
                      label: 'Taken',
                      value: '$takenCount',
                    ),
                    const SizedBox(width: 8),
                    _StatBox(
                      icon: LucideIcons.star,
                      label: 'Avg Score',
                      value: avgScore > 0 ? '${avgScore.round()}' : '—',
                    ),
                    const SizedBox(width: 8),
                    _StatBox(
                      icon: LucideIcons.pencilLine,
                      label: 'Created',
                      value: '$createdCount',
                    ),
                    const SizedBox(width: 8),
                    _StatBox(
                      icon: LucideIcons.repeat,
                      label: 'Attempts',
                      value: '$totalAttempts',
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
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 13, color: Colors.white.withAlpha(180)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(153),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Row ──────────────────────────────────────────────────────────────────

class _TabRow extends StatelessWidget {
  final int selected;
  final int takenCount;
  final int createdCount;
  final ValueChanged<int> onSelected;

  const _TabRow({
    required this.selected,
    required this.takenCount,
    required this.createdCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('Taken by Me', takenCount),
      ('Created by Me', createdCount),
    ];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final isSelected = selected == i;
          final (label, count) = tabs[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderStroke,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : AppColors.textMedium,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withAlpha(50)
                              : AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Toolbar ──────────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final _SortValue sortValue;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_SortValue> onSortChanged;

  const _Toolbar({
    required this.searchCtrl,
    required this.sortValue,
    required this.onSearchChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(LucideIcons.search,
                      size: 15, color: AppColors.textLight),
                ),
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: onSearchChanged,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textDark),
                    decoration: const InputDecoration(
                      hintText: 'Search interviews...',
                      hintStyle: TextStyle(
                          fontSize: 13, color: AppColors.textLight),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<_SortValue>(
          initialValue: sortValue,
          onSelected: onSortChanged,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          offset: const Offset(0, 40),
          itemBuilder: (_) => _SortValue.values
              .map(
                (v) => PopupMenuItem(
                  value: v,
                  child: Row(
                    children: [
                      if (v == sortValue)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(LucideIcons.check,
                              size: 13, color: AppColors.primary),
                        )
                      else
                        const SizedBox(width: 21),
                      Text(v.label,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textDark)),
                    ],
                  ),
                ),
              )
              .toList(),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.arrowUpDown,
                    size: 14, color: AppColors.textMedium),
                const SizedBox(width: 6),
                const Text(
                  'Sort',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Interview Card ───────────────────────────────────────────────────────────

class _InterviewCard extends StatelessWidget {
  final InterviewEntity interview;
  final VoidCallback onTap;
  final VoidCallback onTake;
  final VoidCallback? onViewResults;

  const _InterviewCard({
    required this.interview,
    required this.onTap,
    required this.onTake,
    this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    final score = interview.myLatestScore;
    final scoreColor = score == null
        ? AppColors.textLight
        : score >= 85
            ? const Color(0xFF16A34A)
            : score >= 70
                ? const Color(0xFF0D6FAE)
                : score >= 55
                    ? const Color(0xFFD97706)
                    : const Color(0xFFDC2626);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStroke2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: interview.hasAttempted
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF0D6FAE),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CompanyAvatar(
                        name: interview.companyName,
                        logoUrl: interview.companyLogo,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    interview.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Attempt status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: interview.hasAttempted
                                        ? const Color(0xFFF0FDF4)
                                        : const Color(0xFFEFF8FF),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: interview.hasAttempted
                                          ? const Color(0xFF86EFAC)
                                          : const Color(0xFF7EC8EE),
                                    ),
                                  ),
                                  child: Text(
                                    interview.hasAttempted
                                        ? 'Attempted'
                                        : 'Not Attempted',
                                    style: TextStyle(
                                      color: interview.hasAttempted
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF1C7AB8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              interview.companyName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Meta pills
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Pill(
                          icon: LucideIcons.tag,
                          text: interview.interviewType),
                      _Pill(
                          icon: LucideIcons.user,
                          text: interview.role.isNotEmpty
                              ? interview.role
                              : 'General'),
                      _Pill(
                          icon: LucideIcons.repeat,
                          text:
                              '${interview.attemptsCount} attempt${interview.attemptsCount == 1 ? '' : 's'}'),
                      _Pill(
                          icon: LucideIcons.calendar,
                          text: _fmtDate(interview.createdAt)),
                      if (score != null)
                        _ScorePill(score: score, color: scoreColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF5F5F5)),
                  const SizedBox(height: 10),
                  // Action row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTake,
                          icon: Icon(
                            interview.hasAttempted
                                ? LucideIcons.rotateCcw
                                : LucideIcons.play,
                            size: 14,
                          ),
                          label: Text(
                            interview.hasAttempted ? 'Retake' : 'Take',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (onViewResults != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onViewResults,
                            icon: const Icon(LucideIcons.chartBar,
                                size: 14),
                            label: const Text(
                              'Results',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textDark,
                              side: const BorderSide(
                                  color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
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

  String _fmtDate(String date) {
    final d = DateTime.tryParse(date)?.toLocal();
    if (d == null) return '—';
    const m = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${m[d.month]} ${d.day}';
  }
}

// ─── Company Avatar ───────────────────────────────────────────────────────────

class _CompanyAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;
  const _CompanyAvatar({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      if (logoUrl!.endsWith('.svg') || logoUrl!.contains('/svg/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SvgPicture.network(
            logoUrl!,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => _fallback(),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          logoUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'I';
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

// ─── Pill Widgets ─────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppColors.textLight),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final double score;
  final Color color;
  const _ScorePill({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.star, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            '${score.round()}/100',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────

class _DetailSheet extends ConsumerStatefulWidget {
  final InterviewEntity interview;
  const _DetailSheet({required this.interview});

  @override
  ConsumerState<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends ConsumerState<_DetailSheet> {
  List<InterviewSessionEntity>? _sessions;
  bool _sessionsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _sessionsLoading = true);
    final result = await ref.read(listMySessionsUseCaseProvider)(
      ListMySessionsUseCaseParams(interviewId: widget.interview.id),
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _sessions = const [];
        _sessionsLoading = false;
      }),
      (sessions) => setState(() {
        _sessions = sessions.take(3).toList();
        _sessionsLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interview = widget.interview;
    final score = interview.myLatestScore;
    final scoreColor = score == null
        ? AppColors.textLight
        : score >= 85
            ? const Color(0xFF16A34A)
            : score >= 70
                ? const Color(0xFF0D6FAE)
                : score >= 55
                    ? const Color(0xFFD97706)
                    : const Color(0xFFDC2626);

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderStroke2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Text(
                      'Interview Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.x,
                          size: 18, color: AppColors.textMedium),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.borderStroke),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    // Gradient info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1477b8), Color(0xFF0066a8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            interview.companyName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            interview.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _WhiteBadge(interview.interviewType),
                              _WhiteBadge(
                                  '${interview.attemptsCount} attempt${interview.attemptsCount == 1 ? '' : 's'}'),
                              if (score != null)
                                _WhiteBadge('${score.round()}/100'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tech Stack
                    if (interview.techStack.isNotEmpty) ...[
                      _SectionLabel('Tech Stack'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: interview.techStack
                            .asMap()
                            .entries
                            .map((entry) {
                          final idx = entry.key;
                          final tech = entry.value;
                          final iconUrl = idx <
                                  interview.techStackIconUrls.length
                              ? interview.techStackIconUrls[idx]
                              : null;
                          return _TechChip(name: tech, iconUrl: iconUrl);
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Score details (if attempted)
                    if (score != null) ...[
                      _SectionLabel('Latest Score'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: scoreColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: scoreColor.withAlpha(60)),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.star,
                                size: 20, color: scoreColor),
                            const SizedBox(width: 12),
                            Text(
                              '${score.round()} / 100',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: scoreColor,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: scoreColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _scoreBand(score.round()),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: scoreColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Recent Attempts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel('Recent Attempts'),
                        if (_sessions != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.borderStroke),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_sessions!.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_sessionsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    else if (_sessions == null || _sessions!.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderStroke),
                        ),
                        child: const Text(
                          'No attempts found for this interview yet.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textLight,
                          ),
                        ),
                      )
                    else
                      ..._sessions!.map((session) => _SessionRow(session: session)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Action footer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: AppColors.borderStroke)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          AppRoutes.push(
                            context,
                            InterviewDetailPage(interview: interview),
                          );
                        },
                        icon: Icon(
                          interview.hasAttempted
                              ? LucideIcons.rotateCcw
                              : LucideIcons.play,
                          size: 15,
                        ),
                        label: Text(
                          interview.hasAttempted ? 'Retake' : 'Take Interview',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (interview.hasAttempted &&
                        interview.myLatestSessionId != null) ...[
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          AppRoutes.push(
                            context,
                            InterviewFeedbackPage(
                              sessionId: interview.myLatestSessionId!,
                              interviewId: interview.id,
                              immediate: true,
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.chartBar, size: 15),
                        label: const Text(
                          'Results',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textDark,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 13, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _scoreBand(int score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 55) return 'Developing';
    return 'Needs Work';
  }
}

class _WhiteBadge extends StatelessWidget {
  final String text;
  const _WhiteBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String name;
  final String? iconUrl;
  const _TechChip({required this.name, this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconUrl != null && iconUrl!.isNotEmpty) ...[
            SizedBox(
              width: 14,
              height: 14,
              child: iconUrl!.endsWith('.svg') || iconUrl!.contains('/svg/')
                  ? SvgPicture.network(iconUrl!, fit: BoxFit.contain)
                  : Image.network(iconUrl!, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox()),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends ConsumerWidget {
  final InterviewSessionEntity session;
  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = session.totalScore;
    final scoreColor = score == null
        ? AppColors.textLight
        : score >= 85
            ? const Color(0xFF16A34A)
            : score >= 70
                ? const Color(0xFF0D6FAE)
                : score >= 55
                    ? const Color(0xFFD97706)
                    : const Color(0xFFDC2626);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFECECF0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fmtDateTime(session.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: score != null
                      ? scoreColor.withAlpha(20)
                      : AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  score != null ? '${score.round()}/100' : '—/100',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: score != null ? scoreColor : AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  AppRoutes.push(
                    context,
                    InterviewFeedbackPage(sessionId: session.id, immediate: true),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFD8DDE4)),
                  ),
                  child: const Text(
                    'Feedback',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDateTime(String date) {
    final d = DateTime.tryParse(date)?.toLocal();
    if (d == null) return '—';
    const m = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${m[d.month]} ${d.day}, ${d.year} · $hour:$min $ampm';
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isSearch;
  final String tabLabel;
  const _EmptyState({required this.isSearch, required this.tabLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
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
              child: const Icon(
                LucideIcons.calendarCheck,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch ? 'No matches found' : 'No interviews $tabLabel yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearch
                  ? 'Try a different search term.'
                  : tabLabel == 'taken'
                      ? 'Head to the Interview Hub to start your first mock interview!'
                      : 'Interviews you create will appear here.',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error Block ──────────────────────────────────────────────────────────────

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(LucideIcons.circleAlert,
                size: 36, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                  color: AppColors.textMedium, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
