import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:kaarya/features/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:kaarya/features/leaderboard/presentation/view_model/leaderboard_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _rankColors = [
  Color(0xFF38BDF8), // #1 Champion   – sky-400
  Color(0xFFA5B4FC), // #2 Runner-up  – indigo-300
  Color(0xFF6EE7B7), // #3 3rd Place  – emerald-300
];
const _youBadge = Color(0xFF4F46E5);
const _gold = Color(0xFFFFD700);
const _silver = Color(0xFFC0C0C0);
const _bronze = Color(0xFFCD7F32);

// ─── Screen ───────────────────────────────────────────────────────────────────

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _scope = 'global';

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadLeaderboard);
  }

  String? get _selectedCollegeId {
    final collegeState = ref.read(collegeDashboardViewModelProvider);
    return collegeState.selectedWorkspace?.collegeId ??
        collegeState.workspaces?.firstOrNull?.collegeId;
  }

  void _loadLeaderboard() {
    final isCollege = ref.read(isCollegeProvider);
    final isRecruiter = ref.read(isRecruiterProvider);
    final collegeId = _selectedCollegeId;

    // College role: always college leaderboard
    if (isCollege && collegeId != null) {
      ref
          .read(leaderboardViewModelProvider.notifier)
          .loadLeaderboard(scope: 'college', collegeId: collegeId);
      return;
    }
    // Recruiter: always global
    if (isRecruiter) {
      ref
          .read(leaderboardViewModelProvider.notifier)
          .loadLeaderboard(scope: 'global');
      return;
    }
    // Candidate: use _scope; when college scope, pass collegeId
    ref
        .read(leaderboardViewModelProvider.notifier)
        .loadLeaderboard(
          scope: _scope,
          collegeId: _scope == 'college' ? collegeId : null,
        );
  }

  Future<void> _refresh() {
    final isCollege = ref.read(isCollegeProvider);
    final isRecruiter = ref.read(isRecruiterProvider);
    final collegeId = _selectedCollegeId;

    if (isCollege && collegeId != null) {
      return ref
          .read(leaderboardViewModelProvider.notifier)
          .loadLeaderboard(scope: 'college', collegeId: collegeId);
    }
    if (isRecruiter) {
      return ref
          .read(leaderboardViewModelProvider.notifier)
          .loadLeaderboard(scope: 'global');
    }
    return ref
        .read(leaderboardViewModelProvider.notifier)
        .loadLeaderboard(
          scope: _scope,
          collegeId: _scope == 'college' ? collegeId : null,
        );
  }

  void _switchScope(String scope) {
    if (_scope == scope) return;
    setState(() => _scope = scope);
    final collegeId = _selectedCollegeId;
    ref
        .read(leaderboardViewModelProvider.notifier)
        .loadLeaderboard(
          scope: scope,
          collegeId: scope == 'college' ? collegeId : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isRecruiter = ref.watch(isRecruiterProvider);
    final isCollege = ref.watch(isCollegeProvider);
    final collegeState = ref.watch(collegeDashboardViewModelProvider);
    final hasCollegeWorkspaces =
        collegeState.workspacesStatus == CollegeDashboardLoadStatus.loaded &&
        (collegeState.workspaces?.isNotEmpty ?? false);

    // Show scope toggle only for candidates who are in a college workspace
    final showScopeToggle = !isRecruiter && !isCollege && hasCollegeWorkspaces;

    final state = ref.watch(leaderboardViewModelProvider);
    final data = state.leaderboard;
    final isLoading = state.isLoading;

    final pageEntries = data?.entries ?? [];
    final top3 = pageEntries.length >= 3
        ? pageEntries.take(3).toList()
        : <LeaderboardEntryEntity>[];
    final rest = pageEntries.length > 3
        ? pageEntries.skip(3).toList()
        : (top3.length == 3 ? <LeaderboardEntryEntity>[] : pageEntries);

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _HeroBanner(data: data),
              const SizedBox(height: 16),
              if (showScopeToggle) ...[
                _ScopeToggle(
                  scope: _scope,
                  onChanged: isLoading ? (_) {} : _switchScope,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 20),
              if (isLoading && data == null)
                const SizedBox(height: 300, child: LoaderWidget())
              else if (state.error != null && data == null)
                _ErrorState(message: state.error, onRetry: _refresh)
              else if (data != null) ...[
                if (top3.length == 3) ...[
                  _PodiumSection(
                    top3: top3,
                    currentUserId: data.currentUserEntry?.userId,
                  ),
                  const SizedBox(height: 20),
                ],
                if (rest.isNotEmpty) ...[
                  _RankingTable(
                    entries: rest,
                    currentUserId: data.currentUserEntry?.userId,
                    showFromRank: top3.length == 3 ? 4 : 1,
                  ),
                  const SizedBox(height: 20),
                ],
                const _KRankGuideCard(),
              ],
            ],
          ),
        ),
        if (isLoading && data != null)
          Positioned.fill(
            child: Container(
              color: appOverlayColor(context),
              child: const Center(child: LoaderWidget()),
            ),
          ),
      ],
    );
  }
}

// ─── Hero Banner ─────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final LeaderboardEntity? data;
  const _HeroBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final me = data?.currentUserEntry;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.trophy, size: 18, color: _gold),
                  const SizedBox(width: 8),
                  const Text(
                    'Leaderboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Compete with peers and climb the K-Rank',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _StatBox(
                    label: 'Total',
                    value: data != null ? '${data!.totalEntries}' : '—',
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'Your Rank',
                    value: me?.rank.isNotEmpty == true ? '#${me!.rank}' : '—',
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'Your K-Rank',
                    value: me != null && me.kRank > 0 ? '${me.kRank}' : '—',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(153),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Scope Toggle ─────────────────────────────────────────────────────────────

class _ScopeToggle extends StatelessWidget {
  final String scope;
  final ValueChanged<String> onChanged;
  final bool isLoading;

  const _ScopeToggle({
    required this.scope,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: appSurfaceColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: Row(
        children: [
          _ScopeTab(
            label: 'Global Board',
            icon: LucideIcons.globe,
            selected: scope == 'global',
            onTap: isLoading ? null : () => onChanged('global'),
          ),
          _ScopeTab(
            label: 'College Board',
            icon: LucideIcons.graduationCap,
            selected: scope == 'college',
            onTap: isLoading ? null : () => onChanged('college'),
          ),
        ],
      ),
    );
  }
}

class _ScopeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _ScopeTab({
    required this.label,
    required this.icon,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected
                    ? Colors.white
                    : (isDisabled
                          ? appTextSecondaryColor(context).withAlpha(128)
                          : appTextSecondaryColor(context)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : (isDisabled
                            ? appTextSecondaryColor(context).withAlpha(180)
                            : appTextSecondaryColor(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Podium Section ───────────────────────────────────────────────────────────

class _PodiumSection extends StatelessWidget {
  final List<LeaderboardEntryEntity> top3;
  final String? currentUserId;
  const _PodiumSection({required this.top3, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final rank1 = top3[0];
    final rank2 = top3[1];
    final rank3 = top3[2];

    // Stair-step layout: #1 sits at top, #2 and #3 drop down via top padding.
    // All cards maintain equal height regardless of badge visibility.
    const double sideStep = 24.0; // #2 and #3 both drop the same amount

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.medal, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Top Rankings',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: appTextPrimaryColor(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // #2 — Runner-up (drops step2)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: sideStep),
                child: _PodiumCard(
                  entry: rank2,
                  rank: 2,
                  color: _rankColors[1],
                  medalColor: _silver,
                  label: 'Runner-up',
                  isCurrentUser: currentUserId == rank2.userId,
                  isChampion: false,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // #1 — Champion (top of the stair)
            Expanded(
              child: _PodiumCard(
                entry: rank1,
                rank: 1,
                color: _rankColors[0],
                medalColor: _gold,
                label: 'Champion',
                isCurrentUser: currentUserId == rank1.userId,
                isChampion: true,
              ),
            ),
            const SizedBox(width: 8),
            // #3 — 3rd Place (drops step3)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: sideStep),
                child: _PodiumCard(
                  entry: rank3,
                  rank: 3,
                  color: _rankColors[2],
                  medalColor: _bronze,
                  label: '3rd Place',
                  isCurrentUser: currentUserId == rank3.userId,
                  isChampion: false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final LeaderboardEntryEntity entry;
  final int rank;
  final Color color;
  final Color medalColor;
  final String label;
  final bool isCurrentUser;
  final bool isChampion;

  const _PodiumCard({
    required this.entry,
    required this.rank,
    required this.color,
    required this.medalColor,
    required this.label,
    required this.isCurrentUser,
    required this.isChampion,
  });

  // Darken the rank color so it's always readable on a white background.
  Color get _textColor {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness(hsl.lightness.clamp(0.0, 0.38)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurfaceColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withAlpha(isChampion ? 90 : 55),
          width: isChampion ? 1.5 : 1,
        ),
        boxShadow: isChampion
            ? null
            : [
                BoxShadow(
                  color: color.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          children: [
            // Accent top bar (thicker for champion)
            Container(height: isChampion ? 5 : 4, color: color),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
              child: Column(
                children: [
                  // Rank badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: isChampion ? 12 : 11,
                        fontWeight: FontWeight.w800,
                        color: _textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Medal icon + label row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isChampion ? LucideIcons.crown : LucideIcons.medal,
                        size: 11,
                        color: medalColor,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _textColor.withAlpha(160),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Avatar with colored ring
                  _Avatar(
                    name: entry.name,
                    photo: entry.photo,
                    radius: isChampion ? 27.0 : 21.0,
                    borderColor: color,
                    borderWidth: isChampion ? 2.5 : 2.0,
                  ),
                  const SizedBox(height: 7),
                  // Name
                  Text(
                    entry.name,
                    style: TextStyle(
                      fontSize: isChampion ? 12 : 11,
                      fontWeight: FontWeight.w700,
                      color: appTextPrimaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Lv ${entry.level}',
                      style: TextStyle(
                        fontSize: 10,
                        color: _textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // "You" badge — always occupies space to keep all cards same height
                  Visibility(
                    visible: isCurrentUser,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _youBadge,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Metrics grid
                  _MetricsGrid(entry: entry),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final LeaderboardEntryEntity entry;
  const _MetricsGrid({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: appMutedSurfaceColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _MetricCell(
            label: 'XP',
            value: '${entry.xp}',
            color: const Color(0xFF0EA5E9),
          ),
          _vDivider(context),
          _MetricCell(
            label: 'Score',
            value: '${entry.score}',
            color: AppColors.textDark,
          ),
          _vDivider(context),
          _MetricCell(
            label: 'K-Rank',
            value: '${entry.kRank}',
            color: const Color(0xFF0EA5E9),
          ),
        ],
      ),
    );
  }

  Widget _vDivider(BuildContext context) => Container(
    width: 1,
    height: 26,
    color: appBorderColor(context),
    margin: const EdgeInsets.symmetric(horizontal: 2),
  );
}

class _MetricCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: appTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Ranking Table ───────────────────────────────────────────────────────────

class _RankingTable extends StatelessWidget {
  final List<LeaderboardEntryEntity> entries;
  final String? currentUserId;
  final int showFromRank;
  const _RankingTable({
    required this.entries,
    this.currentUserId,
    this.showFromRank = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appSubtleBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDarkMode(context) ? 18 : 6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.list,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'All Rankings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: appTextPrimaryColor(context),
                  ),
                ),
                const Spacer(),
                Text(
                  '${entries.length} shown',
                  style: TextStyle(
                    fontSize: 12,
                    color: appTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: appSubtleBorderColor(context)),
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: appTextSecondaryColor(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Student',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: appTextSecondaryColor(context),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    'XP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: appTextSecondaryColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 40,
                  child: Text(
                    'Score',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: appTextSecondaryColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 52,
                  child: Text(
                    'K-Rank',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: appTextSecondaryColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: appSubtleBorderColor(context)),
          ...entries.asMap().entries.map((mapEntry) {
            final e = mapEntry.value;
            final isLast = mapEntry.key == entries.length - 1;
            final isMe = currentUserId != null && e.userId == currentUserId;
            final displayRank = e.rank.isNotEmpty
                ? e.rank
                : '${mapEntry.key + showFromRank}';
            return _RankRow(
              entry: e,
              displayRank: displayRank,
              isLast: isLast,
              isMe: isMe,
            );
          }),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final LeaderboardEntryEntity entry;
  final String displayRank;
  final bool isLast;
  final bool isMe;
  const _RankRow({
    required this.entry,
    required this.displayRank,
    required this.isLast,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? appSoftSurfaceColor(context) : appSurfaceColor(context),
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: appSubtleBorderColor(context))),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(12))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#$displayRank',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isMe ? AppColors.primary : AppColors.textMedium,
              ),
            ),
          ),
          _Avatar(
            name: entry.name,
            photo: entry.photo,
            radius: 16,
            borderColor: isMe ? AppColors.primary : appBorderColor(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isMe
                              ? AppColors.primary
                              : appTextPrimaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Lv ${entry.level}',
                  style: TextStyle(
                    fontSize: 11,
                    color: appTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${entry.xp}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0EA5E9),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 40,
            child: Text(
              '${entry.score}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 52,
            child: Text(
              '${entry.kRank}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── K-Rank Guide Card ───────────────────────────────────────────────────────

class _KRankGuideCard extends StatefulWidget {
  const _KRankGuideCard();

  @override
  State<_KRankGuideCard> createState() => _KRankGuideCardState();
}

class _KRankGuideCardState extends State<_KRankGuideCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appSubtleBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: appSoftSurfaceColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.info,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'K-Rank Guide',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: appTextPrimaryColor(context),
                          ),
                        ),
                        Text(
                          'How your ranking score is calculated',
                          style: TextStyle(
                            fontSize: 12,
                            color: appTextSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                    color: appTextSecondaryColor(context),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: appSubtleBorderColor(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: appSoftSurfaceColor(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FORMULA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'K-Rank = (XP × quality factor) + (Score × 2)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tiebreaker: Higher Score wins',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Quality Factor',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Score range → XP counted toward K-Rank',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 8),
                  const _QualityTable(),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Icon(
                        LucideIcons.trendingUp,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Level = ⌊XP ÷ 250⌋ + 1  (every 250 XP = +1 level)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'How to boost your K-Rank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _tip(
                    LucideIcons.zap,
                    const Color(0xFF0EA5E9),
                    'Earn XP by updating profile, saving jobs/interviews, applying, and completing activities.',
                  ),
                  const SizedBox(height: 4),
                  _tip(
                    LucideIcons.star,
                    const Color(0xFFF59E0B),
                    'Raise Score with better mock interview results and consistency.',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tip(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _QualityTable extends StatelessWidget {
  const _QualityTable();

  static const _rows = [
    ('80+', '100%', Color(0xFF10B981)),
    ('60–79', '90%', Color(0xFF34D399)),
    ('40–59', '75%', Color(0xFFF59E0B)),
    ('20–39', '55%', Color(0xFFFB923C)),
    ('1–19', '35%', Color(0xFFEF4444)),
    ('0', '20%', Color(0xFF9CA3AF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Column(
          children: [
            Container(
              color: AppColors.bgLight,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Score Range',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  Text(
                    'XP Counted',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            ..._rows.asMap().entries.map((e) {
              final isLast = e.key == _rows.length - 1;
              final (range, pct, color) = e.value;
              return Container(
                decoration: isLast
                    ? null
                    : const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF0F0F0)),
                        ),
                      ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        range,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        pct,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorState({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(LucideIcons.circleAlert, size: 36, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            message ?? 'Failed to load leaderboard',
            style: const TextStyle(color: AppColors.textMedium, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw, size: 15),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Avatar ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? photo;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  const _Avatar({
    required this.name,
    this.photo,
    required this.radius,
    required this.borderColor,
    this.borderWidth = 2.0,
  });

  String _initials() {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.bgTertiary,
        backgroundImage: photo != null ? NetworkImage(photo!) : null,
        child: photo == null
            ? Text(
                _initials(),
                style: TextStyle(
                  fontSize: math.max(radius * 0.55, 9),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              )
            : null,
      ),
    );
  }
}
