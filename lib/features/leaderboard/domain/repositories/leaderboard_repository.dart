import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/leaderboard/domain/entities/leaderboard_entity.dart';

abstract interface class ILeaderboardRepository {
  Future<Either<Failure, LeaderboardEntity>> getLeaderboard({
    String? scope,
    String? collegeId,
    int? page,
    int? size,
  });
}
