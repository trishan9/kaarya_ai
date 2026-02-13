import 'package:kaarya/features/leaderboard/data/models/leaderboard_api_model.dart';
import 'package:kaarya/features/leaderboard/data/models/leaderboard_hive_model.dart';

abstract interface class ILeaderboardRemoteDataSource {
  Future<LeaderboardApiModel> getLeaderboard({
    String? scope,
    String? collegeId,
    int? page,
    int? size,
  });
}

abstract interface class ILeaderboardLocalDataSource {
  Future<void> saveLeaderboard(LeaderboardHiveModel data);
  Future<LeaderboardHiveModel?> getLeaderboard();
}
