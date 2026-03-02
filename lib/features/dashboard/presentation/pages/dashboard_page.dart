import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/utils/build_icon.dart';
import 'package:kaarya/core/utils/navigation_provider.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/features/jobs/presentation/pages/explore_screen.dart';
import 'package:kaarya/features/interviews/presentation/pages/interview_hub_screen.dart';
import 'package:kaarya/features/dashboard/presentation/pages/leaderboard_screen.dart';
import 'package:kaarya/features/dashboard/presentation/pages/overview_screen.dart';
import 'package:kaarya/features/dashboard/presentation/pages/resume_builder_screen.dart';
import 'package:kaarya/features/companies/presentation/pages/company_settings_page.dart';
import 'package:kaarya/features/recruiter/presentation/pages/company_jobs_screen.dart';
import 'package:kaarya/features/recruiter/presentation/pages/recruiter_overview_screen.dart';
import 'package:kaarya/features/colleges/presentation/pages/college_overview_screen.dart';
import 'package:kaarya/features/colleges/presentation/pages/college_jobs_screen.dart';
import 'package:kaarya/features/colleges/presentation/pages/college_settings_page.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/app_drawer_widget.dart';
import 'package:kaarya/core/widgets/notifications_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const _titles = [
    "Overview",
    "Explore Jobs & Internships",
    "AI Interview Hub",
    "Leaderboard",
    "Resume Builder AI",
  ];

  static const _bottomNavscreens = [
    OverviewScreen(),
    ExploreScreen(),
    InterviewHubScreen(),
    LeaderboardScreen(),
    ResumeBuilderScreen(),
  ];

  int _indexFromDestination(AppDestination dest) {
    return AppDestination.values.indexOf(dest);
  }

  AppDestination _destinationFromIndex(int index) {
    return AppDestination.values[index];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecruiter = ref.watch(isRecruiterProvider);
    final isCollege = ref.watch(isCollegeProvider);
    final dividerColor = Theme.of(context).dividerColor;

    if (isRecruiter) {
      return const _RecruiterDashboard();
    }
    if (isCollege) {
      return const _CollegeDashboard();
    }

    final destination = ref.watch(bottomNavProvider);
    final selectedIndex = _indexFromDestination(destination);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const NotificationsWidget(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: dividerColor),
        ),
      ),

      drawer: AppDrawerWidget(),

      body: _bottomNavscreens[selectedIndex],

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            color: dividerColor,
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: selectedIndex == index ? double.infinity : 0,
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: (i) {
              ref.read(bottomNavProvider.notifier).state =
                  _destinationFromIndex(i);
            },
            items: [
              BottomNavigationBarItem(
                icon: buildIcon(
                  assetPath: 'assets/icons/overview_outlined.svg',
                  isActive: false,
                ),
                activeIcon: buildIcon(
                  assetPath: 'assets/icons/overview.svg',
                  isActive: true,
                  width: 26,
                  height: 26,
                ),
                label: "Overview",
              ),

              BottomNavigationBarItem(
                icon: buildIcon(
                  assetPath: 'assets/icons/explore_outlined.svg',
                  isActive: false,
                  width: 26,
                  height: 26,
                ),
                activeIcon: buildIcon(
                  assetPath: 'assets/icons/explore.svg',
                  isActive: true,
                  width: 26,
                  height: 26,
                ),
                label: "Explore",
              ),

              BottomNavigationBarItem(
                icon: buildIcon(
                  assetPath: 'assets/icons/interview_outlined.svg',
                  isActive: false,
                  width: 26,
                  height: 26,
                ),
                activeIcon: buildIcon(
                  assetPath: 'assets/icons/interview.svg',
                  isActive: true,
                  width: 26,
                  height: 26,
                ),
                label: "Interview Hub",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard_outlined),
                activeIcon: Icon(Icons.leaderboard),
                label: "Leaderboard",
              ),

              BottomNavigationBarItem(
                icon: buildIcon(
                  assetPath: 'assets/icons/resume_ai.svg',
                  isActive: false,
                ),
                activeIcon: buildIcon(
                  assetPath: 'assets/icons/resume_ai.svg',
                  isActive: true,
                ),
                label: "Resume Builder AI",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecruiterDashboard extends ConsumerWidget {
  const _RecruiterDashboard();

  static const _recruiterTitles = [
    "Overview",
    "Company Jobs",
    "Leaderboard",
    "Company Settings",
  ];

  static const _recruiterScreens = [
    RecruiterOverviewScreen(),
    CompanyJobsScreen(),
    LeaderboardScreen(),
    CompanySettingsPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = ref.watch(recruiterNavProvider);
    final selectedIndex = _recruiterIndexFromDest(destination);
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _recruiterTitles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const NotificationsWidget(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: dividerColor),
        ),
      ),
      drawer: AppDrawerWidget(),
      body: _recruiterScreens[selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            color: dividerColor,
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: selectedIndex == index ? double.infinity : 0,
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: (i) {
              ref.read(recruiterNavProvider.notifier).state =
                  _recruiterDestFromIndex(i);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.layoutDashboard),
                activeIcon: Icon(LucideIcons.layoutDashboard),
                label: "Overview",
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.briefcaseBusiness),
                activeIcon: Icon(LucideIcons.briefcaseBusiness),
                label: "College Jobs",
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.trophy),
                activeIcon: Icon(LucideIcons.trophy),
                label: "Leaderboard",
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.settings2),
                activeIcon: Icon(LucideIcons.settings2),
                label: "Settings",
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _recruiterIndexFromDest(RecruiterDestination dest) {
    const order = [
      RecruiterDestination.overview,
      RecruiterDestination.companyJobs,
      RecruiterDestination.leaderboard,
      RecruiterDestination.settings,
    ];
    final i = order.indexOf(dest);
    return i >= 0 ? i : 0;
  }

  RecruiterDestination _recruiterDestFromIndex(int index) {
    const order = [
      RecruiterDestination.overview,
      RecruiterDestination.companyJobs,
      RecruiterDestination.leaderboard,
      RecruiterDestination.settings,
    ];
    return order[index.clamp(0, order.length - 1)];
  }
}

class _CollegeDashboard extends ConsumerWidget {
  const _CollegeDashboard();

  static const _collegeTitles = [
    "College Overview",
    "College Jobs",
    "Leaderboard",
    "College Settings",
  ];

  static const _collegeScreens = [
    CollegeOverviewScreen(),
    CollegeJobsScreen(),
    LeaderboardScreen(),
    CollegeSettingsPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = ref.watch(collegeNavProvider);
    final selectedIndex = _collegeIndexFromDest(destination);
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _collegeTitles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const NotificationsWidget(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: dividerColor),
        ),
      ),
      drawer: AppDrawerWidget(),
      drawerScrimColor: Colors.black54,
      body: _collegeScreens[selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            color: dividerColor,
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: selectedIndex == index ? double.infinity : 0,
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: (i) {
              ref.read(collegeNavProvider.notifier).state =
                  _collegeDestFromIndex(i);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.layoutDashboard),
                activeIcon: Icon(LucideIcons.layoutDashboard),
                label: "Overview",
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.briefcaseBusiness),
                activeIcon: Icon(LucideIcons.briefcaseBusiness),
                label: "College Jobs",
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.trophy),
                activeIcon: Icon(LucideIcons.trophy),
                label: "Leaderboard",
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.settings2),
                activeIcon: Icon(LucideIcons.settings2),
                label: "Settings",
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _collegeIndexFromDest(CollegeDestination dest) {
    const order = [
      CollegeDestination.overview,
      CollegeDestination.collegeJobs,
      CollegeDestination.leaderboard,
      CollegeDestination.collegeSettings,
    ];
    final i = order.indexOf(dest);
    return i >= 0 ? i : 0;
  }

  CollegeDestination _collegeDestFromIndex(int index) {
    const order = [
      CollegeDestination.overview,
      CollegeDestination.collegeJobs,
      CollegeDestination.leaderboard,
      CollegeDestination.collegeSettings,
    ];
    return order[index.clamp(0, order.length - 1)];
  }
}
