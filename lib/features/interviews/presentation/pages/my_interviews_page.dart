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
              children: const [
                Text(
                  'My Interview History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track your mock interviews and review past performances.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No interviews yet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your scheduled and completed interviews will appear here.\nHead to AI Interview Hub to get started!',
            style: TextStyle(fontSize: 14, color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Explore Interviews',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
