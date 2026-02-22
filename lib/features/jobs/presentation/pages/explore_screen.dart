import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/job_card_widget.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';
import 'package:kaarya/features/jobs/presentation/view_model/jobs_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum ExploreJobTab { forYou, trending, newThisWeek, remote }

enum ExploreSortValue {
  recommended,
  newest,
  salaryHighToLow,
  salaryLowToHigh,
  titleAsc,
  companyAsc,
}

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  ExploreJobTab _selectedTab = ExploreJobTab.forYou;
  ExploreSortValue _sortBy = ExploreSortValue.recommended;
  ExploreFilterState _filters = const ExploreFilterState();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(jobsViewModelProvider);
      if (!state.isLoading && state.section == null) {
        ref.read(jobsViewModelProvider.notifier).loadJobsSection();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsViewModelProvider);
    final jobsData = jobsState.section;

    final selectedJobs = _selectedJobs(jobsData);
    final filterOptions = _buildFilterOptions(selectedJobs);
    final visibleJobs = _visibleJobs(selectedJobs);

    return RefreshIndicator(
      onRefresh: () async {
        await _refreshJobsFromApi(forceRefresh: true);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _buildHero(),
          const SizedBox(height: 16),
          _buildToolbar(filterOptions),
          const SizedBox(height: 12),
          _buildTabs(),
          const SizedBox(height: 14),
          if (jobsState.isLoading && jobsData == null)
            const SizedBox(height: 220, child: LoaderWidget())
          else if (jobsState.error != null && jobsData == null)
            _ErrorBlock(
              message: jobsState.error ?? "Unable to load jobs",
              onRetry: () => _refreshJobsFromApi(forceRefresh: true),
            )
          else
            ..._buildJobList(visibleJobs),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
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
                "Explore Your Career Opportunities Here",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Apply to jobs & internships that match your skills and aspirations, and embark on a rewarding career journey.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _heroField(
                      controller: _searchController,
                      icon: LucideIcons.search300,
                      hint: "Search your job title or keyword...",
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade200,
                    ),
                    _heroField(
                      controller: _locationController,
                      icon: LucideIcons.mapPin300,
                      hint: "Set your country or timezone...",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () => _refreshJobsFromApi(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDCECF7),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(LucideIcons.search, size: 18),
                  label: const Text("Find Job"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ExploreFilterOptions filterOptions) {
    final activeFilterCount = _filters.count;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Jobs For You", style: Theme.of(context).textTheme.headlineSmall),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _openSortSheet,
              icon: const Icon(LucideIcons.arrowDownUp300, size: 16),
              label: const Text('Sort', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _openFilterSheet(filterOptions),
              icon: const Icon(LucideIcons.slidersHorizontal300, size: 16),
              label: Text(
                activeFilterCount > 0
                    ? 'Filter ($activeFilterCount)'
                    : 'Filter',
                style: const TextStyle(fontSize: 13),
              ),
              style: activeFilterCount > 0
                  ? OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    )
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ExploreJobTab.values.map((tab) {
          final selected = _selectedTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _labelForTab(tab),
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? Colors.white : AppColors.textDark,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              showCheckmark: false,
              selected: selected,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              onSelected: (_) {
                setState(() {
                  _selectedTab = tab;
                  _filters = const ExploreFilterState();
                });
                _refreshJobsFromApi(forceRefresh: true);
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildJobList(List<JobEntity> jobs) {
    if (jobs.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "No jobs matched your current filters.",
            style: TextStyle(color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    return List.generate(jobs.length, (index) {
      final job = jobs[index];
      return Padding(
        padding: EdgeInsets.only(bottom: index == jobs.length - 1 ? 0 : 12),
        child: JobCardWidget(
          job: job,
          onBookmark: () async {
            final vm = ref.read(jobsViewModelProvider.notifier);
            final newSaved = !job.isSaved;
            vm.updateJobBookmarkState(job.id, newSaved);
            final ok = await vm.toggleBookmark(job.id, newSaved);
            if (ok != true && mounted) {
              vm.updateJobBookmarkState(job.id, job.isSaved);
              SnackbarUtils.showError(context, "Failed to update bookmark");
            }
          },
        ),
      );
    });
  }

  List<JobEntity> _selectedJobs(JobsSectionEntity? jobsData) {
    if (jobsData == null) return const <JobEntity>[];

    switch (_selectedTab) {
      case ExploreJobTab.forYou:
        return jobsData.jobs.forYou;
      case ExploreJobTab.trending:
        return jobsData.jobs.trending;
      case ExploreJobTab.newThisWeek:
        return jobsData.jobs.newThisWeek;
      case ExploreJobTab.remote:
        return jobsData.jobs.remote;
    }
  }

  List<JobEntity> _visibleJobs(List<JobEntity> input) {
    final filtered = input.where((job) {
      final status = _statusLabelForJob(job);
      final statusMatch =
          _filters.statusLabels.isEmpty ||
          _filters.statusLabels.contains(status);
      final employmentMatch =
          _filters.employmentTypes.isEmpty ||
          _filters.employmentTypes.contains(job.employmentType);
      final engagementMatch =
          _filters.engagementTypes.isEmpty ||
          _filters.engagementTypes.contains(job.engagementType);
      final locationMatch =
          _filters.locations.isEmpty ||
          _filters.locations.contains(job.location);
      return statusMatch && employmentMatch && engagementMatch && locationMatch;
    }).toList();

    switch (_sortBy) {
      case ExploreSortValue.recommended:
        return filtered;
      case ExploreSortValue.newest:
        filtered.sort(
          (left, right) =>
              _timeAge(left.createdAt).compareTo(_timeAge(right.createdAt)),
        );
        return filtered;
      case ExploreSortValue.salaryHighToLow:
        filtered.sort(
          (left, right) => _salaryMax(
            right.salaryRange,
          ).compareTo(_salaryMax(left.salaryRange)),
        );
        return filtered;
      case ExploreSortValue.salaryLowToHigh:
        filtered.sort(
          (left, right) => _salaryMin(
            left.salaryRange,
          ).compareTo(_salaryMin(right.salaryRange)),
        );
        return filtered;
      case ExploreSortValue.titleAsc:
        filtered.sort((left, right) => left.title.compareTo(right.title));
        return filtered;
      case ExploreSortValue.companyAsc:
        filtered.sort(
          (left, right) => left.companyName.compareTo(right.companyName),
        );
        return filtered;
    }
  }

  ExploreFilterOptions _buildFilterOptions(List<JobEntity> jobs) {
    final statuses = <String>{};
    final employment = <String>{};
    final engagement = <String>{};
    final locations = <String>{};

    for (final job in jobs) {
      statuses.add(_statusLabelForJob(job));
      employment.add(job.employmentType);
      engagement.add(job.engagementType);
      locations.add(job.location);
    }

    return ExploreFilterOptions(
      statusLabels: statuses.toList()..sort(),
      employmentTypes: employment.toList()..sort(),
      engagementTypes: engagement.toList()..sort(),
      locations: locations.toList()..sort(),
    );
  }

  String _labelForTab(ExploreJobTab tab) {
    switch (tab) {
      case ExploreJobTab.forYou:
        return "For You";
      case ExploreJobTab.trending:
        return "Trending Jobs";
      case ExploreJobTab.newThisWeek:
        return "New This Week";
      case ExploreJobTab.remote:
        return "Remote Opportunities";
    }
  }

  String _statusLabelForJob(JobEntity job) {
    if (job.status == 'closed') return "Closed Hiring";
    if (job.status == 'draft') return "Draft";
    return "Open Hiring";
  }

  int _timeAge(String createdAt) {
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return 999999999;
    return DateTime.now().difference(parsed).inSeconds;
  }

  int _salaryMin(String salaryRange) {
    final values = _salaryValues(salaryRange);
    if (values.isEmpty) return 0;
    return values.first;
  }

  int _salaryMax(String salaryRange) {
    final values = _salaryValues(salaryRange);
    if (values.isEmpty) return 0;
    return values.length > 1 ? values[1] : values.first;
  }

  List<int> _salaryValues(String salaryRange) {
    final matches = RegExp(r'[\d,]+').allMatches(salaryRange);
    return matches
        .map((item) => int.tryParse(item.group(0)!.replaceAll(',', '')) ?? 0)
        .toList();
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<ExploreSortValue>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sort jobs",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...ExploreSortValue.values.map(
                  (value) => InkWell(
                    onTap: () => Navigator.of(context).pop(value),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _sortBy == value
                            ? const Color(0xFFF8F9FA)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _sortBy == value
                              ? AppColors.primary
                              : const Color(0xFFF0F0F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _sortLabel(value),
                              style: TextStyle(
                                fontWeight: _sortBy == value
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _sortBy == value
                                    ? AppColors.primary
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                          if (_sortBy == value)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _sortBy = selected;
      });
    }
  }

  Future<void> _openFilterSheet(ExploreFilterOptions options) async {
    final selected = await showModalBottomSheet<ExploreFilterState>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        var temp = _filters;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  6,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Filter jobs",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Choose filters to narrow down matching roles",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textMedium),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                temp = const ExploreFilterState();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.borderStroke,
                              ),
                            ),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                      _filterGroup(
                        title: "Status",
                        values: options.statusLabels,
                        selected: temp.statusLabels,
                        onToggle: (value, checked) {
                          setSheetState(() {
                            temp = temp.toggleStatus(value, checked);
                          });
                        },
                      ),
                      _filterGroup(
                        title: "Job Type",
                        values: options.employmentTypes,
                        selected: temp.employmentTypes,
                        onToggle: (value, checked) {
                          setSheetState(() {
                            temp = temp.toggleEmployment(value, checked);
                          });
                        },
                      ),
                      _filterGroup(
                        title: "Mode",
                        values: options.engagementTypes,
                        selected: temp.engagementTypes,
                        onToggle: (value, checked) {
                          setSheetState(() {
                            temp = temp.toggleEngagement(value, checked);
                          });
                        },
                      ),
                      _filterGroup(
                        title: "Location",
                        values: options.locations,
                        selected: temp.locations,
                        onToggle: (value, checked) {
                          setSheetState(() {
                            temp = temp.toggleLocation(value, checked);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(temp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            temp.count > 0
                                ? "Apply Filters (${temp.count})"
                                : "Apply Filters",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _filters = selected;
      });
      await _refreshJobsFromApi(forceRefresh: true);
    }
  }

  Widget _filterGroup({
    required String title,
    required List<String> values,
    required Set<String> selected,
    required void Function(String value, bool checked) onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 4),
          if (values.isEmpty)
            const Text(
              "No options",
              style: TextStyle(fontSize: 12, color: AppColors.textMedium),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: values.map((value) {
                final isSelected = selected.contains(value);
                return FilterChip(
                  label: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textDark,
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
                  onSelected: (checked) => onToggle(value, checked),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE0E0E0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _sortLabel(ExploreSortValue value) {
    switch (value) {
      case ExploreSortValue.recommended:
        return "Recommended";
      case ExploreSortValue.newest:
        return "Newest";
      case ExploreSortValue.salaryHighToLow:
        return "Salary: High to Low";
      case ExploreSortValue.salaryLowToHigh:
        return "Salary: Low to High";
      case ExploreSortValue.titleAsc:
        return "Title: A-Z";
      case ExploreSortValue.companyAsc:
        return "Company: A-Z";
    }
  }

  Widget _heroField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13),
      onSubmitted: (_) {
        _refreshJobsFromApi();
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMedium, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMedium),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Future<void> _refreshJobsFromApi({bool forceRefresh = true}) async {
    final search = _searchController.text.trim();
    final typedLocation = _locationController.text.trim();
    final filteredLocation = _singleValueOrNull(_filters.locations);

    await ref
        .read(jobsViewModelProvider.notifier)
        .loadJobsSection(
          searchQuery: search.isNotEmpty ? search : null,
          locationQuery: typedLocation.isNotEmpty
              ? typedLocation
              : filteredLocation,
          status: _apiStatus(_filters.statusLabels),
          employmentType: _singleValueOrNull(_filters.employmentTypes),
          engagementType: _singleValueOrNull(_filters.engagementTypes),
        );
  }

  String? _singleValueOrNull(Set<String> values) {
    if (values.length != 1) return null;
    return values.first;
  }

  String? _apiStatus(Set<String> labels) {
    if (labels.length != 1) return null;
    switch (labels.first) {
      case 'Open Hiring':
        return 'open';
      case 'Closed Hiring':
        return 'closed';
      case 'Draft':
        return 'draft';
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

class ExploreFilterOptions {
  final List<String> statusLabels;
  final List<String> employmentTypes;
  final List<String> engagementTypes;
  final List<String> locations;

  const ExploreFilterOptions({
    required this.statusLabels,
    required this.employmentTypes,
    required this.engagementTypes,
    required this.locations,
  });
}

class ExploreFilterState {
  final Set<String> statusLabels;
  final Set<String> employmentTypes;
  final Set<String> engagementTypes;
  final Set<String> locations;

  const ExploreFilterState({
    this.statusLabels = const <String>{},
    this.employmentTypes = const <String>{},
    this.engagementTypes = const <String>{},
    this.locations = const <String>{},
  });

  int get count =>
      statusLabels.length +
      employmentTypes.length +
      engagementTypes.length +
      locations.length;

  ExploreFilterState toggleStatus(String value, bool checked) {
    return ExploreFilterState(
      statusLabels: _toggle(statusLabels, value, checked),
      employmentTypes: employmentTypes,
      engagementTypes: engagementTypes,
      locations: locations,
    );
  }

  ExploreFilterState toggleEmployment(String value, bool checked) {
    return ExploreFilterState(
      statusLabels: statusLabels,
      employmentTypes: _toggle(employmentTypes, value, checked),
      engagementTypes: engagementTypes,
      locations: locations,
    );
  }

  ExploreFilterState toggleEngagement(String value, bool checked) {
    return ExploreFilterState(
      statusLabels: statusLabels,
      employmentTypes: employmentTypes,
      engagementTypes: _toggle(engagementTypes, value, checked),
      locations: locations,
    );
  }

  ExploreFilterState toggleLocation(String value, bool checked) {
    return ExploreFilterState(
      statusLabels: statusLabels,
      employmentTypes: employmentTypes,
      engagementTypes: engagementTypes,
      locations: _toggle(locations, value, checked),
    );
  }

  Set<String> _toggle(Set<String> source, String value, bool checked) {
    final next = <String>{...source};
    if (checked) {
      next.add(value);
    } else {
      next.remove(value);
    }
    return next;
  }
}
