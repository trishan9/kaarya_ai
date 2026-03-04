import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/app_drawer_widget.dart';
import 'package:kaarya/core/widgets/notifications_widget.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/navigation_provider.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';
import 'package:kaarya/features/resources/presentation/state/resource_state.dart';
import 'package:kaarya/features/resources/presentation/view_model/resource_view_model.dart';
import 'package:kaarya/features/resources/presentation/pages/resource_course_detail_page.dart';
import 'package:kaarya/features/resources/presentation/widgets/create_course_sheet.dart';

enum _ResourceTab { mine, publicLibrary }

class ResourcesHubScreen extends ConsumerStatefulWidget {
  const ResourcesHubScreen({super.key});

  @override
  ConsumerState<ResourcesHubScreen> createState() => _ResourcesHubScreenState();
}

class _ResourcesHubScreenState extends ConsumerState<ResourcesHubScreen> {
  _ResourceTab _selectedTab = _ResourceTab.mine;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(pushedPageProvider.notifier).state = PushedPageKeys.resources;
      ref.read(resourceViewModelProvider.notifier).loadCourses();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(resourceViewModelProvider.notifier).loadCourses(
      difficulty: _selectedDifficulty,
      forceRefresh: true,
    );
  }

  List<ResourceCourseEntity> _filtered(
    List<ResourceCourseEntity> courses,
    String? currentUserId,
  ) {
    if (_selectedTab == _ResourceTab.publicLibrary) {
      return courses.where((c) => c.visibility == 'public').toList();
    }
    // My Resources: courses created by the current user
    if (currentUserId != null && currentUserId.isNotEmpty) {
      return courses.where((c) => c.createdBy == currentUserId).toList();
    }
    return [...courses];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourceViewModelProvider);
    final currentUserId = ref.watch(userSessionServiceProvider).getCurrentUserId();
    final courses = state.coursesListData?.courses ?? [];
    final filteredCourses = _filtered(courses, currentUserId);
    final isLoading = state.coursesListStatus == ResourceLoadStatus.loading && courses.isEmpty;
    final isError = state.coursesListStatus == ResourceLoadStatus.error && courses.isEmpty;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(pushedPageProvider.notifier).state = null;
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NotificationsWidget(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
      ),
      drawer: AppDrawerWidget(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            // ── Hero ────────────────────────────────────────────────────────
            _buildHero(),
            const SizedBox(height: 16),

            // ── Toolbar (Difficulty Filter) ─────────────────────────────────
            _buildToolbar(),
            const SizedBox(height: 12),

            // ── Tabs ────────────────────────────────────────────────────────
            _buildTabs(courses, currentUserId),
            const SizedBox(height: 12),

            // ── Content ─────────────────────────────────────────────────────
            if (isLoading)
              const SizedBox(height: 220, child: LoaderWidget())
            else if (isError)
              _buildError(state.coursesListErrorMessage)
            else if (filteredCourses.isEmpty)
              _buildEmpty()
            else
              ..._buildCourseCards(filteredCourses),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateCourseSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    ),
    );
  }

  // ─── Hero ───────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Master Your Skills with AI Resources",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Learn role-specific skills through AI-generated chapters, concepts, and interview prep materials tailored to your goals.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => showCreateCourseSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(40),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: BorderSide(color: Colors.white.withAlpha(50)),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text(
                    "Generate New Resource",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Toolbar ────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "All Resources",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        _buildDifficultyFilter(),
      ],
    );
  }

  Widget _buildDifficultyFilter() {
    const options = ['All Levels', 'beginner', 'intermediate', 'advanced'];
    const labels = {
      'All Levels': 'All',
      'beginner': 'Beginner',
      'intermediate': 'Intermediate',
      'advanced': 'Advanced',
    };
    final current = _selectedDifficulty ?? 'All Levels';
    final isFiltered = _selectedDifficulty != null;

    return PopupMenuButton<String>(
      initialValue: current,
      onSelected: (v) {
        final diff = v == 'All Levels' ? null : v;
        setState(() => _selectedDifficulty = diff);
        ref.read(resourceViewModelProvider.notifier).loadCourses(
          difficulty: diff,
        );
      },
      itemBuilder: (ctx) => options
          .map((d) => PopupMenuItem(value: d, child: Text(labels[d]!)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isFiltered ? AppColors.primary.withAlpha(25) : AppColors.bgLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isFiltered ? AppColors.primary : AppColors.borderStroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.slidersHorizontal300,
              size: 14,
              color: isFiltered ? AppColors.primary : AppColors.textLight,
            ),
            const SizedBox(width: 6),
            Text(
              labels[current] ?? 'All',
              style: TextStyle(
                fontSize: 12,
                color: isFiltered ? AppColors.primary : AppColors.textLight,
                fontWeight: isFiltered ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tabs ───────────────────────────────────────────────────────────────

  Widget _buildTabs(List<ResourceCourseEntity> courses, String? currentUserId) {
    final myCount = currentUserId != null && currentUserId.isNotEmpty
        ? courses.where((c) => c.createdBy == currentUserId).length
        : courses.length;
    final publicCount = courses.where((c) => c.visibility == 'public').length;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          _tabOption(_ResourceTab.mine, LucideIcons.bookMarked, 'My Resources', myCount),
          _tabOption(_ResourceTab.publicLibrary, LucideIcons.globe, 'Public Library', publicCount),
        ],
      ),
    );
  }

  Widget _tabOption(_ResourceTab tab, IconData icon, String label, int count) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textMedium,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(50)
                      : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Course Cards ───────────────────────────────────────────────────────

  List<Widget> _buildCourseCards(List<ResourceCourseEntity> courses) {
    return courses
        .map((course) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCourseCard(course),
            ))
        .toList();
  }

  Widget _buildCourseCard(ResourceCourseEntity course) {
    final isPublic = course.visibility == 'public';
    final isInterviewPrep = course.generationMode == 'interview_prep';

    return GestureDetector(
      onTap: () => AppRoutes.push(
        context,
        ResourceCourseDetailPage(courseId: course.id),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderStroke2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                  if (course.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _badge(course.category, color: const Color(0xFFEAF4FF), textColor: const Color(0xFF0D5D9B)),
                      _badge(_capitalize(course.difficulty)),
                      _badge(isInterviewPrep ? 'Interview Prep' : 'Learn'),
                      ...course.targetRoles.take(2).map((r) => _badge(r, small: true)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFBFDFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border(top: BorderSide(color: AppColors.borderStroke2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(LucideIcons.bookOpen, size: 13, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    '${course.chaptersCount} chapters',
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isPublic ? LucideIcons.globe : LucideIcons.lock,
                    size: 12,
                    color: isPublic ? AppColors.success2 : AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPublic ? 'Public' : 'Private',
                    style: TextStyle(
                      fontSize: 12,
                      color: isPublic ? AppColors.success2 : AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(LucideIcons.arrowRight, size: 14, color: AppColors.textLight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, {Color? color, Color? textColor, bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color ?? AppColors.bgLight,
        borderRadius: BorderRadius.circular(4),
        border: color == null ? Border.all(color: AppColors.borderStroke) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          color: textColor ?? AppColors.textLight,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ─── Error & Empty States ──────────────────────────────────────────────

  Widget _buildError(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleAlert, size: 48, color: AppColors.error.withAlpha(160)),
            const SizedBox(height: 12),
            Text(
              message ?? 'Failed to load resources',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(LucideIcons.rotateCcw, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.bookOpen, size: 48, color: AppColors.primary.withAlpha(160)),
            const SizedBox(height: 12),
            const Text(
              'No resources found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Generate your first AI course to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
