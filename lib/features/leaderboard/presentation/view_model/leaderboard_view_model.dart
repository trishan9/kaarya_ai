import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:kaarya/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:kaarya/features/leaderboard/presentation/state/leaderboard_state.dart';

final leaderboardViewModelProvider =
    NotifierProvider<LeaderboardViewModel, LeaderboardState>(
      () => LeaderboardViewModel(),
    );

class LeaderboardViewModel extends Notifier<LeaderboardState> {
  @override
  LeaderboardState build() => LeaderboardState.initial();

  ILeaderboardRepository get _repo => ref.read(leaderboardRepositoryProvider);

  Future<void> loadLeaderboard({
    String? scope,
    String? collegeId,
    int? page,
    int? size,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, scope: scope);
    final result = await _repo.getLeaderboard(
      scope: scope ?? state.scope,
      collegeId: collegeId,
      page: page,
      size: size,
    );
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (leaderboard) =>
          state = state.copyWith(isLoading: false, leaderboard: leaderboard),
    );
  }

  void switchScope(String scope) {
    loadLeaderboard(scope: scope);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
