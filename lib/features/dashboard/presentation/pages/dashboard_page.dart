import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/utils/build_icon.dart';
import 'package:kaarya/core/utils/navigation_provider.dart';
import 'package:kaarya/features/dashboard/presentation/pages/explore_screen.dart';
import 'package:kaarya/features/dashboard/presentation/pages/interview_hub_screen.dart';
import 'package:kaarya/features/dashboard/presentation/pages/leaderboard_screen.dart';
import 'package:kaarya/features/dashboard/presentation/pages/overview_screen.dart';
import 'package:kaarya/features/dashboard/presentation/pages/resume_builder_screen.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/app_drawer_widget.dart';
import 'package:kaarya/core/widgets/notifications_widget.dart';

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
    final destination = ref.watch(bottomNavProvider);
    final selectedIndex = _indexFromDestination(destination);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[selectedIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: NotificationsWidget(),
          ),
        ],
      ),

      drawer: AppDrawerWidget(),

      body: _bottomNavscreens[selectedIndex],

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            color: Colors.grey.shade300,
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 3,
                    color: selectedIndex == index
                        ? AppColors.primary
                        : Colors.transparent,
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
