import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppDrawerWidget extends StatelessWidget {
  final int selectedIndex;

  const AppDrawerWidget({super.key, this.selectedIndex = 1});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(12), child: _header()),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _searchBar(),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("MAIN"),
                      _menuItem(
                        icon: LucideIcons.layoutDashboard,
                        title: "Overview",
                        selected: true,
                      ),
                      _menuItem(
                        icon: LucideIcons.globe,
                        title: "Explore Jobs & Internships",
                      ),
                      _menuItem(
                        icon: LucideIcons.sparkles,
                        title: "Resume Builder AI",
                      ),
                      _menuItem(
                        icon: LucideIcons.mic,
                        title: "AI Interview Hub",
                      ),
                      _menuItem(
                        icon: LucideIcons.calendarCheck,
                        title: "My Interviews",
                      ),
                      _menuItem(
                        icon: Icons.leaderboard_outlined,
                        title: "Leaderboard",
                      ),
                      _menuItem(
                        icon: LucideIcons.folder,
                        title: "My Applications",
                      ),
                      _menuItem(icon: LucideIcons.bookmark, title: "Saved"),
                      _menuItem(icon: LucideIcons.fileText, title: "Resources"),

                      const SizedBox(height: 16),

                      _sectionTitle("OTHERS"),
                      _menuItem(
                        icon: LucideIcons.newspaper,
                        title: "Blogs & Articles",
                      ),
                      _menuItem(
                        icon: LucideIcons.headphones,
                        title: "Help Center",
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _profileCard(),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        onPressed: () {},
                        label: Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        icon: Icon(LucideIcons.logOut, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Image.asset("assets/images/kaarya_logo.png", width: 38),
        SizedBox(width: 10),
        Text(
          "Kaarya",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Quick search...",
        prefixIcon: const Icon(LucideIcons.search, size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _menuItem({
    IconData? icon,
    Widget? customIcon,
    required String title,
    bool selected = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.all(0),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading:
            customIcon ??
            Icon(icon, size: 20, color: selected ? Colors.white : Colors.black),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: selected ? Colors.white : Colors.black,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.borderStroke2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(child: Image.asset("assets/images/profile.png")),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Trishan Wagle",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2),
                Text(
                  "@trishan_wagle9",
                  style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_up),
        ],
      ),
    );
  }
}
