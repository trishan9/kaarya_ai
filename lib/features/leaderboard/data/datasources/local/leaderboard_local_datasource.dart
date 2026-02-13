import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/leaderboard/data/datasources/leaderboard_datasource.dart';
import 'package:kaarya/features/leaderboard/data/models/leaderboard_hive_model.dart';

final leaderboardLocalDatasourceProvider =
    Provider<ILeaderboardLocalDataSource>((ref) {
      return LeaderboardLocalDataSource(
        hiveService: ref.read(hiveServiceProvider),
      );
    });

class LeaderboardLocalDataSource implements ILeaderboardLocalDataSource {
  final HiveService _hiveService;

  LeaderboardLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveLeaderboard(LeaderboardHiveModel data) async {
    await _hiveService.saveLeaderboard(data);
  }

  @override
  Future<LeaderboardHiveModel?> getLeaderboard() async {
    return _hiveService.getLeaderboard();
  }
}
