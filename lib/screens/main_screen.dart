import 'package:flutter/material.dart';
import 'package:kaarya/common/build_icon.dart';
import 'package:kaarya/screens/main_screens/explore_screen.dart';
import 'package:kaarya/screens/main_screens/interview_hub_screen.dart';
import 'package:kaarya/screens/main_screens/leaderboard_screen.dart';
import 'package:kaarya/screens/main_screens/overview_screen.dart';
import 'package:kaarya/screens/main_screens/resume_builder_screen.dart';
import 'package:kaarya/theme/app_colors.dart';
import 'package:kaarya/widgets/app_drawer_widget.dart';
import 'package:kaarya/widgets/notifications_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> lstBottomScreens = [
    const OverviewScreen(),
    const ExploreScreen(),
    const InterviewHubScreen(),
    const LeaderboardScreen(),
    const ResumeBuilderScreen(),
  ];

  final List<String> _titles = [
    "Overview",
    "Explore Jobs & Internships",
    "AI Interview Hub",
    "Leaderboard",
    "Resume Builder AI",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: NotificationsWidget(),
          ),
        ],
      ),
      drawer: AppDrawerWidget(),
      body: lstBottomScreens[_selectedIndex],
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
                    color: _selectedIndex == index
                        ? AppColors.primary
                        : Colors.transparent,
                  ),
                );
              }),
            ),
          ),

          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
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
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
