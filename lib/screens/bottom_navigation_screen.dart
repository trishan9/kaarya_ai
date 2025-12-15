import 'package:flutter/material.dart';
import 'package:kaarya/screens/bottom_screen/overview_screen.dart';
import 'package:kaarya/theme/app_colors.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;
  List<Widget> lstBottomScreens = [
    const OverviewScreen(),
    const OverviewScreen(),
    const OverviewScreen(),
    const OverviewScreen(),
    const OverviewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                activeIcon: Icon(Icons.dashboard_rounded),
                icon: Icon(Icons.dashboard_outlined),
                label: "Overview",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.explore),
                icon: Icon(Icons.explore_outlined),
                label: "Explore",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.work),
                icon: Icon(Icons.work_outline_outlined),
                label: "InterviewAI",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.leaderboard),
                icon: Icon(Icons.leaderboard_outlined),
                label: "Leaderboard",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.document_scanner),
                icon: Icon(Icons.document_scanner_outlined),
                label: "ResumeAI",
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
