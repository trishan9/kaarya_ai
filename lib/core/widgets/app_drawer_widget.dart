import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/navigation_provider.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/features/auth/presentation/pages/login_page.dart';
import 'package:kaarya/features/auth/presentation/pages/settings_page.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:kaarya/features/dashboard/presentation/pages/my_applications_page.dart';
import 'package:kaarya/features/bookmarks/presentation/pages/saved_page.dart';
import 'package:kaarya/features/interviews/presentation/pages/my_interviews_page.dart';
import 'package:kaarya/features/resources/presentation/pages/resources_hub_screen.dart';
import 'package:kaarya/features/recruiter/presentation/pages/post_new_job_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppDrawerWidget extends ConsumerStatefulWidget {
  const AppDrawerWidget({super.key});

  @override
  ConsumerState<AppDrawerWidget> createState() => _AppDrawerWidgetState();
}

class _AppDrawerWidgetState extends ConsumerState<AppDrawerWidget> {
  List<Widget> _buildRecruiterNav(
    void Function(dynamic) goToRecruiterDest,
    void Function(Widget) pushPage,
  ) {
    final current = ref.watch(recruiterNavProvider);
    return [
      _sectionLabel('WORKSPACE'),
      _navItem(
        icon: LucideIcons.layoutDashboard,
        title: 'Overview',
        selected: current == RecruiterDestination.overview,
        onTap: () => goToRecruiterDest(RecruiterDestination.overview),
      ),
      _navItem(
        icon: LucideIcons.briefcase,
        title: 'Company Jobs',
        selected: current == RecruiterDestination.companyJobs,
        onTap: () => goToRecruiterDest(RecruiterDestination.companyJobs),
      ),
      _navItem(
        icon: LucideIcons.plus,
        title: 'Post New Job',
        selected: current == RecruiterDestination.postNewJob,
        onTap: () {
          AppRoutes.pop(context);
          AppRoutes.pushNoTransition(context, const PostNewJobPage());
        },
      ),
      _navItem(
        icon: LucideIcons.calendar,
        title: 'Interview Management',
        selected: current == RecruiterDestination.interviewManagement,
        onTap: () {},
      ),
      _navItem(
        icon: LucideIcons.trophy,
        title: 'Leaderboard',
        selected: current == RecruiterDestination.leaderboard,
        onTap: () => goToRecruiterDest(RecruiterDestination.leaderboard),
      ),
      const SizedBox(height: 8),
      _sectionLabel('OTHERS'),
      _navItem(
        icon: LucideIcons.bookOpen,
        title: 'Resources',
        onTap: () => pushPage(const ResourcesHubScreen()),
      ),
      _navItem(
        icon: LucideIcons.settings,
        title: 'Settings',
        onTap: () => pushPage(const SettingsPage()),
      ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildCandidateNav(
    AppDestination current,
    String? pushedPage,
    void Function(AppDestination) goToBottom,
    void Function(Widget) pushPage,
  ) {
    return [
      _sectionLabel('MAIN'),
      _navItem(
        icon: LucideIcons.layoutDashboard,
        title: 'Overview',
        selected: pushedPage == null && current == AppDestination.overview,
        onTap: () => goToBottom(AppDestination.overview),
      ),
      _navItem(
        icon: LucideIcons.globe,
        title: 'Explore Jobs',
        selected: pushedPage == null && current == AppDestination.explore,
        onTap: () => goToBottom(AppDestination.explore),
      ),
      _navItem(
        icon: LucideIcons.sparkles,
        title: 'Resume Builder AI',
        selected: pushedPage == null && current == AppDestination.resumeBuilder,
        onTap: () => goToBottom(AppDestination.resumeBuilder),
      ),
      _navItem(
        icon: LucideIcons.mic,
        title: 'AI Interview Hub',
        selected: pushedPage == null && current == AppDestination.interviewHub,
        onTap: () => goToBottom(AppDestination.interviewHub),
      ),
      _navItem(
        icon: LucideIcons.bookOpen,
        title: 'Learning Resources',
        selected: pushedPage == 'resources',
        onTap: () => pushPage(const ResourcesHubScreen()),
      ),
      _navItem(
        icon: LucideIcons.trophy,
        title: 'Leaderboard',
        selected: pushedPage == null && current == AppDestination.leaderboard,
        onTap: () => goToBottom(AppDestination.leaderboard),
      ),
      const SizedBox(height: 8),
      _sectionLabel('YOUR ACTIVITY'),
      _navItem(
        icon: LucideIcons.folder,
        title: 'My Applications',
        onTap: () => pushPage(const MyApplicationsPage()),
      ),
      _navItem(
        icon: LucideIcons.calendarCheck,
        title: 'My Interviews',
        onTap: () => pushPage(const MyInterviewsPage()),
      ),
      _navItem(
        icon: LucideIcons.bookmark,
        title: 'Saved',
        onTap: () => pushPage(const SavedPage()),
      ),
      const SizedBox(height: 8),
      _sectionLabel('OTHERS'),
      _navItem(
        icon: LucideIcons.settings,
        title: 'Settings',
        onTap: () => pushPage(const SettingsPage()),
      ),
      const SizedBox(height: 20),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isRecruiter = ref.watch(isRecruiterProvider);
    final current = ref.watch(bottomNavProvider);
    final pushedPage = ref.watch(pushedPageProvider);
    final session = ref.watch(userSessionServiceProvider);
    final userName = session.getCurrentUserFullName() ?? 'User';
    final userEmail = session.getCurrentUserEmail() ?? '';
    final userPhoto = session.getCurrentUserProfilePicture() ?? '';

    void goToBottom(AppDestination dest) {
      ref.read(pushedPageProvider.notifier).state = null;
      ref.read(bottomNavProvider.notifier).state = dest;
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    void goToRecruiterDest(dynamic dest) {
      ref.read(pushedPageProvider.notifier).state = null;
      ref.read(recruiterNavProvider.notifier).state = dest;
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    void pushPage(Widget page) {
      AppRoutes.pop(context);
      AppRoutes.push(context, page);
    }

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Image.asset('assets/images/kaarya_logo.png', width: 36),
                  const SizedBox(width: 10),
                  const Text(
                    'Kaarya',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Quick search...',
                    hintStyle: const TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(LucideIcons.search,
                        size: 18, color: AppColors.textMedium),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: isRecruiter ? _buildRecruiterNav(goToRecruiterDest, pushPage) : _buildCandidateNav(current, pushedPage, goToBottom, pushPage),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _userAvatar(userPhoto, userName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isRecruiter) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Recruiter',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isRecruiter)
                          const Text(
                            'Recruiter access',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showLogoutDialog(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.logOut,
                        size: 18,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _userAvatar(String photoUrl, String name) {
    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(photoUrl),
      );
    }
    final parts = name.split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : 'U';
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.bgSecondary,
      child: Text(
        initials,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textMedium,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String title,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(
          icon,
          size: 20,
          color: selected ? Colors.white : AppColors.textLight,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: selected ? Colors.white : AppColors.textDark,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.logOut,
                size: 24,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Logout',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to sign out of your account?',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => AppRoutes.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.borderStroke),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      AppRoutes.pop(ctx);
                      await ref.read(authViewModelProvider.notifier).logoutUser();
                      ref.read(dashboardViewModelProvider.notifier).resetState();
                      if (context.mounted) {
                        AppRoutes.pushAndRemoveUntil(context, const LoginPage());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
