import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_section_entity.dart';
import 'package:kaarya/features/interviews/presentation/pages/create_interview_page.dart';
import 'package:kaarya/features/interviews/presentation/pages/interview_detail_page.dart';
import 'package:kaarya/features/interviews/presentation/pages/interview_feedback_page.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum InterviewHubTab { forYou, trending, newThisWeek, allTimePopular, byYou }

enum InterviewSortValue {
  recommended,
  popular,
  recent,
  scoreHighToLow,
  titleAsc,
  companyAsc,
}

class InterviewHubScreen extends ConsumerStatefulWidget {
  const InterviewHubScreen({super.key});

  @override
  ConsumerState<InterviewHubScreen> createState() => _InterviewHubScreenState();
}

class _InterviewHubScreenState extends ConsumerState<InterviewHubScreen> {
  static const Map<String, String> _icons = {
    'react':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg',
    'typescript':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/typescript/typescript-original.svg',
    'javascript':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/javascript/javascript-original.svg',
    'node':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg',
    'flutter':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg',
    'dart':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg',
    'firebase':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/firebase/firebase-plain.svg',
    'next':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nextjs/nextjs-original.svg',
    'mongodb':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mongodb/mongodb-original.svg',
    'postgresql':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/postgresql/postgresql-original.svg',
    'mysql':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg',
    'docker':
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg',
  };

  InterviewHubTab _tab = InterviewHubTab.forYou;
  InterviewSortValue _sort = InterviewSortValue.recommended;
  InterviewFilterState _filters = const InterviewFilterState();
  final Map<String, bool> _savedOverride = <String, bool>{};
  final Set<String> _savingIds = <String>{};
  final Set<String> _actionIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardViewModelProvider.notifier).loadInterviews(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final interviews = _visible(_selected(state.interviewsData));
    final filterOptions = _buildFilterOptions(_selected(state.interviewsData));

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(dashboardViewModelProvider.notifier)
            .loadInterviews(forceRefresh: true);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _hero(),
          const SizedBox(height: 16),
          _toolbar(filterOptions),
          const SizedBox(height: 10),
          _tabs(),
          const SizedBox(height: 12),
          if (state.interviewsStatus == DashboardLoadStatus.loading &&
              state.interviewsData == null)
            const SizedBox(height: 220, child: LoaderWidget())
          else if (state.interviewsStatus == DashboardLoadStatus.error &&
              state.interviewsData == null)
            _ErrorBlock(
              message:
                  state.interviewsErrorMessage ?? "Unable to load interviews",
              onRetry: () => ref
                  .read(dashboardViewModelProvider.notifier)
                  .loadInterviews(forceRefresh: true),
            )
          else if (interviews.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                "No interviews available in this category yet.",
                style: TextStyle(color: AppColors.textMedium),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...interviews.map(_card),
        ],
      ),
    );
  }

  Widget _hero() {
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
                "Simulate Industry-Level Interviews with AI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Get interview ready on your targeted roles with AI mock interviews. Practice on real interview questions and get instant feedback to improve your skills.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateInterviewPage(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(40),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: BorderSide(color: Colors.white.withAlpha(50)),
                  ),
                  child: const Text(
                    'Create Custom Interview',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: InterviewHubTab.values.map((tab) {
          final selected = tab == _tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _tabLabel(tab),
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? Colors.white : appTextPrimaryColor(context),
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
              backgroundColor: appSurfaceColor(context),
              side: BorderSide(
                color: selected ? AppColors.primary : appBorderColor(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onSelected: (_) {
                setState(() {
                  _tab = tab;
                  _filters = const InterviewFilterState();
                });
                _refreshFromApi();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _toolbar(InterviewFilterOptions options) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Interviews", style: Theme.of(context).textTheme.headlineSmall),
        OutlinedButton.icon(
          onPressed: () => _openFilter(options),
          icon: const Icon(LucideIcons.slidersHorizontal300, size: 16),
          label: Text(
            _filters.count == 0 ? "Filter" : "Filter (${_filters.count})",
            style: const TextStyle(fontSize: 13),
          ),
          style: _filters.count > 0
              ? OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                )
              : null,
        ),
      ],
    );
  }

  Widget _card(InterviewEntity interview) {
    final busySave = _savingIds.contains(interview.id);
    final busyAction = _actionIds.contains(interview.id);
    final saved = _savedOverride[interview.id] ?? interview.isSaved;
    // Use backend icon URLs when available, else fall back to client-side mapping
    final techUrls = interview.techStackIconUrls.isNotEmpty
        ? interview.techStackIconUrls.take(3).toList()
        : _techUrls(interview.techStack);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appSurfaceColor(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: appSubtleBorderColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDarkMode(context) ? 18 : 8),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _typeLabel(interview.interviewType),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                Text(
                  "${interview.attemptsCount} people took this!",
                  style: TextStyle(
                    color: appTextSecondaryColor(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _avatar(interview),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interview.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "by ${interview.companyName}",
                        style: TextStyle(color: appTextSecondaryColor(context)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: techUrls
                      .map(
                        (url) => Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: appMutedSurfaceColor(context),
                            child: SvgPicture.network(
                              url,
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                              placeholderBuilder: (_) => const Icon(
                                LucideIcons.codeXml300,
                                size: 14,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _pill(LucideIcons.clock300, _createdLabel(interview.createdAt)),
                _pill(
                  LucideIcons.gauge300,
                  interview.myLatestScore == null
                      ? "Your Score: -/100"
                      : "Your Score: ${interview.myLatestScore!.toStringAsFixed(1)}/100",
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (interview.hasAttempted &&
                    interview.myLatestSessionId != null) ...[
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: busyAction
                            ? null
                            : () => _onAction(interview),
                        child: busyAction
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Review Results',
                                style: TextStyle(fontSize: 13),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => _onRetake(interview),
                        child: const Text(
                          'Re-take',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ] else
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: busyAction
                            ? null
                            : () => _onAction(interview),
                        child: busyAction
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
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
                    onTap: busySave ? null : () => _onSave(interview, !saved),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: appBorderColor(context)),
                      ),
                      child: busySave
                          ? const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              saved
                                  ? LucideIcons.bookmarkCheck
                                  : LucideIcons.bookmark,
                              color: saved
                                  ? AppColors.primary
                                  : AppColors.textLight,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave(InterviewEntity row, bool nextSaved) async {
    setState(() => _savingIds.add(row.id));
    final failure = await ref
        .read(dashboardViewModelProvider.notifier)
        .setInterviewSaved(interviewId: row.id, isSaved: nextSaved);
    if (!mounted) return;
    setState(() {
      _savingIds.remove(row.id);
      if (failure == null) _savedOverride[row.id] = nextSaved;
    });
    if (failure != null) _snack(failure.message);
  }

  void _onRetake(InterviewEntity row) {
    AppRoutes.push(context, InterviewDetailPage(interview: row));
  }

  void _onAction(InterviewEntity row) {
    if (row.hasAttempted && row.myLatestSessionId != null) {
      AppRoutes.push(
        context,
        InterviewFeedbackPage(
          sessionId: row.myLatestSessionId!,
          interviewId: row.id,
        ),
      );
      return;
    }

    AppRoutes.push(context, InterviewDetailPage(interview: row));
  }

  void _snack(String message) {
    SnackbarUtils.showInfo(context, message);
  }

  Future<void> _openFilter(InterviewFilterOptions options) async {
    final selected = await showModalBottomSheet<InterviewFilterState>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        var temp = _filters;
        return StatefulBuilder(
          builder: (context, setSheet) => SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  6,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Filter interviews",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Narrow down by category, attempt, and company",
                              style: TextStyle(color: AppColors.textMedium),
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () => setSheet(() {
                            temp = const InterviewFilterState();
                          }),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.borderStroke,
                            ),
                          ),
                          child: const Text("Clear"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _group(
                      title: "Category",
                      values: options.categories,
                      selected: temp.categories,
                      onToggle: (v, c) =>
                          setSheet(() => temp = temp.toggleCategory(v, c)),
                    ),
                    _group(
                      title: "Attempt",
                      values: options.attemptStatuses,
                      selected: temp.attemptStatuses,
                      label: (v) =>
                          v == 'attempted' ? 'Attempted' : 'Not attempted',
                      onToggle: (v, c) =>
                          setSheet(() => temp = temp.toggleAttempt(v, c)),
                    ),
                    _group(
                      title: "Company",
                      values: options.companies,
                      selected: temp.companies,
                      onToggle: (v, c) =>
                          setSheet(() => temp = temp.toggleCompany(v, c)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(temp),
                        child: Text("Apply Filters (${temp.count})"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _filters = selected);
      await _refreshFromApi();
    }
  }

  Widget _group({
    required String title,
    required List<String> values,
    required Set<String> selected,
    String Function(String)? label,
    required void Function(String, bool) onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (values.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "No options",
                style: TextStyle(color: AppColors.textMedium),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: values.map((value) {
                final isSelected = selected.contains(value);
                return FilterChip(
                  label: Text(
                    label?.call(value) ?? value,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : appTextPrimaryColor(context),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: appSurfaceColor(context),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : appBorderColor(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onSelected: (checked) => onToggle(value, checked),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  List<InterviewEntity> _selected(InterviewsSectionEntity? data) {
    if (data == null) return const <InterviewEntity>[];
    switch (_tab) {
      case InterviewHubTab.forYou:
        return data.forYou;
      case InterviewHubTab.trending:
        return data.trending;
      case InterviewHubTab.newThisWeek:
        return data.newThisWeek;
      case InterviewHubTab.allTimePopular:
        return data.allTimePopular;
      case InterviewHubTab.byYou:
        return data.byYou;
    }
  }

  List<InterviewEntity> _visible(List<InterviewEntity> rows) {
    final filtered = rows.where((row) {
      final category = _typeLabel(row.interviewType);
      final attempt = row.hasAttempted ? 'attempted' : 'not_attempted';
      final c =
          _filters.categories.isEmpty || _filters.categories.contains(category);
      final a =
          _filters.attemptStatuses.isEmpty ||
          _filters.attemptStatuses.contains(attempt);
      final m =
          _filters.companies.isEmpty ||
          _filters.companies.contains(row.companyName);
      return c && a && m;
    }).toList();

    switch (_sort) {
      case InterviewSortValue.recommended:
        return filtered;
      case InterviewSortValue.popular:
        filtered.sort((l, r) => r.attemptsCount.compareTo(l.attemptsCount));
        return filtered;
      case InterviewSortValue.recent:
        filtered.sort((l, r) => _ts(r.createdAt).compareTo(_ts(l.createdAt)));
        return filtered;
      case InterviewSortValue.scoreHighToLow:
        filtered.sort(
          (l, r) => (r.myLatestScore ?? -1).compareTo(l.myLatestScore ?? -1),
        );
        return filtered;
      case InterviewSortValue.titleAsc:
        filtered.sort((l, r) => l.title.compareTo(r.title));
        return filtered;
      case InterviewSortValue.companyAsc:
        filtered.sort((l, r) => l.companyName.compareTo(r.companyName));
        return filtered;
    }
  }

  InterviewFilterOptions _buildFilterOptions(List<InterviewEntity> rows) {
    final categories = <String>{};
    final attempts = <String>{};
    final companies = <String>{};
    for (final row in rows) {
      categories.add(_typeLabel(row.interviewType));
      attempts.add(row.hasAttempted ? 'attempted' : 'not_attempted');
      companies.add(row.companyName);
    }
    return InterviewFilterOptions(
      categories: categories.toList()..sort(),
      attemptStatuses: attempts.toList()..sort(),
      companies: companies.toList()..sort(),
    );
  }

  Widget _avatar(InterviewEntity row) {
    final logo = row.companyLogo;
    if (logo != null && logo.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          logo,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(row.companyName),
        ),
      );
    }
    return _fallback(row.companyName);
  }

  Widget _fallback(String company) {
    final initial = company.isEmpty ? 'K' : company[0].toUpperCase();
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(initial, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: appMutedSurfaceColor(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: appTextSecondaryColor(context)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: appTextSecondaryColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _tabLabel(InterviewHubTab value) {
    switch (value) {
      case InterviewHubTab.forYou:
        return "For You";
      case InterviewHubTab.trending:
        return "Trending Interviews";
      case InterviewHubTab.newThisWeek:
        return "New This Week";
      case InterviewHubTab.allTimePopular:
        return "All Time Popular";
      case InterviewHubTab.byYou:
        return "By You";
    }
  }

  String _typeLabel(String value) {
    switch (value) {
      case 'technical':
        return "Technical";
      case 'behavioral':
        return "Behavioral";
      case 'system_design':
        return "System Design";
      case 'custom':
        return "Custom";
      default:
        return "Mixed";
    }
  }

  String _createdLabel(String createdAt) {
    final date = DateTime.tryParse(createdAt)?.toLocal();
    if (date == null) return "Created on: -";
    return "Created on: ${_month(date.month)} ${date.day}, ${date.year}";
  }

  String _month(int month) {
    const names = <String>[
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month];
  }

  int _ts(String value) =>
      DateTime.tryParse(value)?.millisecondsSinceEpoch ?? 0;

  List<String> _techUrls(List<String> techs) {
    final urls = <String>[];
    for (final tech in techs) {
      final t = tech.toLowerCase();
      final matched = _icons.keys.where((k) => t.contains(k));
      if (matched.isNotEmpty) urls.add(_icons[matched.first]!);
      if (urls.length == 3) break;
    }
    return urls;
  }

  Future<void> _refreshFromApi() async {
    await ref
        .read(dashboardViewModelProvider.notifier)
        .loadInterviews(
          forceRefresh: true,
          interviewType: _apiInterviewType(_filters.categories),
          sortBy: _apiSortBy(_sort),
          attemptFilter: _apiAttemptFilter(_filters.attemptStatuses),
        );
  }

  String? _apiSortBy(InterviewSortValue value) {
    switch (value) {
      case InterviewSortValue.popular:
        return 'popular';
      case InterviewSortValue.recent:
        return 'newest';
      case InterviewSortValue.titleAsc:
        return 'title';
      case InterviewSortValue.recommended:
      case InterviewSortValue.scoreHighToLow:
      case InterviewSortValue.companyAsc:
        return null;
    }
  }

  String? _apiAttemptFilter(Set<String> values) {
    if (values.length != 1) return null;
    final value = values.first;
    if (value == 'attempted' || value == 'not_attempted') {
      return value;
    }
    return null;
  }

  String? _apiInterviewType(Set<String> values) {
    if (values.length != 1) return null;
    final value = values.first;
    switch (value) {
      case 'Technical':
        return 'technical';
      case 'Behavioral':
        return 'behavioral';
      case 'System Design':
        return 'system_design';
      case 'Custom':
        return 'custom';
      default:
        return null;
    }
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}

class InterviewFilterOptions {
  final List<String> categories;
  final List<String> attemptStatuses;
  final List<String> companies;

  const InterviewFilterOptions({
    required this.categories,
    required this.attemptStatuses,
    required this.companies,
  });
}

class InterviewFilterState {
  final Set<String> categories;
  final Set<String> attemptStatuses;
  final Set<String> companies;

  const InterviewFilterState({
    this.categories = const <String>{},
    this.attemptStatuses = const <String>{},
    this.companies = const <String>{},
  });

  int get count =>
      categories.length + attemptStatuses.length + companies.length;

  InterviewFilterState toggleCategory(String value, bool checked) {
    return InterviewFilterState(
      categories: _toggle(categories, value, checked),
      attemptStatuses: attemptStatuses,
      companies: companies,
    );
  }

  InterviewFilterState toggleAttempt(String value, bool checked) {
    return InterviewFilterState(
      categories: categories,
      attemptStatuses: _toggle(attemptStatuses, value, checked),
      companies: companies,
    );
  }

  InterviewFilterState toggleCompany(String value, bool checked) {
    return InterviewFilterState(
      categories: categories,
      attemptStatuses: attemptStatuses,
      companies: _toggle(companies, value, checked),
    );
  }

  Set<String> _toggle(Set<String> source, String value, bool checked) {
    final copy = <String>{...source};
    if (checked) {
      copy.add(value);
    } else {
      copy.remove(value);
    }
    return copy;
  }
}
