import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/navigation_provider.dart';
import 'package:kaarya/features/auth/presentation/pages/login_page.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kaarya/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppDrawerWidget extends ConsumerStatefulWidget {
  const AppDrawerWidget({super.key});

  @override
  ConsumerState<AppDrawerWidget> createState() => _AppDrawerWidgetState();
}

class _AppDrawerWidgetState extends ConsumerState<AppDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    final current = ref.watch(bottomNavProvider);
    final userSessionService = ref.watch(userSessionServiceProvider);
    final userName = userSessionService.getCurrentUserFullName() ?? 'User';
    final userEmail = userSessionService.getCurrentUserEmail() ?? '';
    final userProfilePicture =
        userSessionService.getCurrentUserProfilePicture() ?? '';

    void goToBottom(AppDestination dest) {
      ref.read(bottomNavProvider.notifier).state = dest;
      AppRoutes.pop(context);
    }

    void pushPage(Widget page) {
      AppRoutes.pop(context);
      AppRoutes.push(context, page);
    }

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

                      _drawerItem(
                        icon: LucideIcons.layoutDashboard,
                        title: "Overview",
                        selected: current == AppDestination.overview,
                        onTap: () => goToBottom(AppDestination.overview),
                      ),

                      _drawerItem(
                        icon: LucideIcons.globe,
                        title: "Explore Jobs & Internships",
                        selected: current == AppDestination.explore,
                        onTap: () => goToBottom(AppDestination.explore),
                      ),

                      _drawerItem(
                        icon: LucideIcons.sparkles,
                        title: "Resume Builder AI",
                        selected: current == AppDestination.resumeBuilder,
                        onTap: () => goToBottom(AppDestination.resumeBuilder),
                      ),

                      _drawerItem(
                        icon: LucideIcons.mic,
                        title: "AI Interview Hub",
                        selected: current == AppDestination.interviewHub,
                        onTap: () => goToBottom(AppDestination.interviewHub),
                      ),

                      _drawerItem(
                        icon: LucideIcons.calendarCheck,
                        title: "My Interviews",
                        onTap: () => pushPage(const DashboardPage()),
                      ),

                      _drawerItem(
                        icon: Icons.leaderboard_outlined,
                        title: "Leaderboard",
                        selected: current == AppDestination.leaderboard,
                        onTap: () => goToBottom(AppDestination.leaderboard),
                      ),

                      _drawerItem(
                        icon: LucideIcons.folder,
                        title: "My Applications",
                        onTap: () => pushPage(const DashboardPage()),
                      ),

                      _drawerItem(
                        icon: LucideIcons.bookmark,
                        title: "Saved",
                        onTap: () => pushPage(const DashboardPage()),
                      ),

                      _drawerItem(
                        icon: LucideIcons.fileText,
                        title: "Resources",
                        onTap: () => pushPage(const DashboardPage()),
                      ),

                      const SizedBox(height: 16),

                      _sectionTitle("OTHERS"),

                      _drawerItem(
                        icon: LucideIcons.newspaper,
                        title: "Blogs & Articles",
                        onTap: () => pushPage(const DashboardPage()),
                      ),

                      _drawerItem(
                        icon: LucideIcons.headphones,
                        title: "Help Center",
                        onTap: () => pushPage(const DashboardPage()),
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.borderStroke2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          userProfilePicture.isNotEmpty
                              ? ClipRRect(
                                  child: Image.network(userProfilePicture),
                                )
                              : ClipRRect(
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      userName[0].toUpperCase() +
                                          userName
                                              .split(" ")[1][0]
                                              .toUpperCase(),

                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),

                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_up),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        onPressed: () => _showLogoutDialog(context),
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

  void _showLogoutDialog(BuildContext context) {
    Future<void> handleLogout() async {
      AppRoutes.pop(context);
      await ref.read(authViewModelProvider.notifier).logoutUser();

      if (context.mounted) {
        AppRoutes.pushAndRemoveUntil(context, const LoginPage());
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => AppRoutes.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: handleLogout,
            child: Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
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

Widget _drawerItem({
  required String title,
  IconData? icon,
  Widget? customIcon,
  bool selected = false,
  required VoidCallback onTap,
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
      onTap: onTap,
    ),
  );
}
