import 'package:kaarya/features/leaderboard/domain/entities/leaderboard_entity.dart';

class LeaderboardState {
  final bool isLoading;
  final String? error;
  final LeaderboardEntity? leaderboard;
  final String scope;

  const LeaderboardState({
    this.isLoading = false,
    this.error,
    this.leaderboard,
    this.scope = 'global',
  });

  factory LeaderboardState.initial() => const LeaderboardState();

  LeaderboardState copyWith({
    bool? isLoading,
    String? error,
    LeaderboardEntity? leaderboard,
    String? scope,
    bool clearError = false,
  }) => LeaderboardState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    leaderboard: leaderboard ?? this.leaderboard,
    scope: scope ?? this.scope,
  );
}
