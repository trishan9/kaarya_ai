import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
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
    Future.microtask(
      () => ref
          .read(leaderboardViewModelProvider.notifier)
          .loadLeaderboard(scope: _scope),
    );
  }

  Future<void> _refresh() =>
      ref.read(leaderboardViewModelProvider.notifier).loadLeaderboard(
            scope: _scope,
          );

  void _switchScope(String scope) {
    if (_scope == scope) return;
    setState(() => _scope = scope);
    ref
        .read(leaderboardViewModelProvider.notifier)
        .loadLeaderboard(scope: scope);
  }

  @override
  Widget build(BuildContext context) {
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _HeroBanner(data: data),
          const SizedBox(height: 16),
          _ScopeToggle(scope: _scope, onChanged: _switchScope),
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
