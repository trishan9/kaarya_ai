import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _scope = 'global';

  static const _gold = Color(0xFFFFD700);
  static const _silver = Color(0xFFC0C0C0);
  static const _bronze = Color(0xFFCD7F32);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(dashboardViewModelProvider.notifier)
          .loadLeaderboard(scope: _scope),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final data = state.leaderboardData;
    final status = state.leaderboardStatus;

    return RefreshIndicator(
      onRefresh: () => ref
          .read(dashboardViewModelProvider.notifier)
          .loadLeaderboard(scope: _scope, forceRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _buildHeroBanner(data),
          const SizedBox(height: 16),
          _buildScopeToggle(),
          const SizedBox(height: 20),
          if (status == DashboardLoadStatus.loading && data == null)
            const SizedBox(height: 300, child: LoaderWidget())
          else if (status == DashboardLoadStatus.error && data == null)
            _buildErrorState(state)
          else if (data != null) ...[
            if (data.entries.length >= 3)
              _buildPodium(data.entries.take(3).toList()),
            const SizedBox(height: 20),
            _buildRankedTable(data.entries),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroBanner(LeaderboardEntity? data) {
    final currentUser = data?.currentUserEntry;

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
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 70,
              height: 70,
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
                'Leaderboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Compete with peers and climb the ranks',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _statBox('Total Entries', '${data?.totalEntries ?? '—'}'),
                  const SizedBox(width: 10),
                  _statBox('Your Rank', currentUser?.rank ?? '—'),
                  const SizedBox(width: 10),
                  _statBox(
                    'Your XP',
                    currentUser != null ? '${currentUser.xp}' : '—',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(153),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeToggle() {
    return Row(
      children: [
        _scopeChip('Global', 'global'),
        const SizedBox(width: 8),
        _scopeChip('College', 'college'),
      ],
    );
  }

  Widget _scopeChip(String label, String value) {
    final selected = _scope == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: selected ? Colors.white : AppColors.textDark,
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
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      onSelected: (_) {
        setState(() => _scope = value);
        ref
            .read(dashboardViewModelProvider.notifier)
            .loadLeaderboard(scope: value, forceRefresh: true);
      },
    );
  }

  Widget _buildErrorState(DashboardState state) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            state.leaderboardErrorMessage ?? 'Failed to load leaderboard',
            style: const TextStyle(color: AppColors.textMedium),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref
                .read(dashboardViewModelProvider.notifier)
                .loadLeaderboard(scope: _scope, forceRefresh: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntryEntity> top) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _podiumSlot(top[1], _silver, 110, 2)),
        Expanded(child: _podiumSlot(top[0], _gold, 140, 1)),
        Expanded(child: _podiumSlot(top[2], _bronze, 90, 3)),
      ],
    );
  }

  Widget _podiumSlot(
    LeaderboardEntryEntity entry,
    Color color,
    double columnHeight,
    int rank,
  ) {
    final avatarRadius = rank == 1 ? 34.0 : 28.0;
    final ringWidth = 3.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: ringWidth),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(60),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: AppColors.bgTertiary,
            backgroundImage: entry.photo != null
                ? NetworkImage(entry.photo!)
                : null,
            child: entry.photo == null
                ? Text(
                    entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: rank == 1 ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${entry.xp} XP',
            style: TextStyle(
              color: color.computeLuminance() > 0.5
                  ? const Color(0xFF6B5900)
                  : color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: columnHeight,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: color.computeLuminance() > 0.5
                  ? const Color(0xFF6B5900)
                  : color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankedTable(List<LeaderboardEntryEntity> entries) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Student',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'XP',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Level',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          ...entries.asMap().entries.map((entry) {
            final e = entry.value;
            final isLast = entry.key == entries.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: e.isCurrentUser ? AppColors.bgSecondary : Colors.white,
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: Color(0xFFF0F0F0)),
                      ),
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(14))
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      e.rank.isEmpty ? '${entry.key + 1}' : e.rank,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: e.isCurrentUser
                            ? AppColors.primary
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.bgTertiary,
                    backgroundImage: e.photo != null
                        ? NetworkImage(e.photo!)
                        : null,
                    child: e.photo == null
                        ? Text(
                            e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: e.isCurrentUser
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                        if (e.college != null)
                          Text(
                            e.college!,
                            style: const TextStyle(
                              color: AppColors.textMedium,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${e.xp}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      e.level,
                      style: const TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
