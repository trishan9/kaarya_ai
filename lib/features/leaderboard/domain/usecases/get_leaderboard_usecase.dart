import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:kaarya/features/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:kaarya/features/leaderboard/domain/repositories/leaderboard_repository.dart';

final getLeaderboardUseCaseProvider = Provider<GetLeaderboardUseCase>((ref) {
  return GetLeaderboardUseCase(
    repository: ref.read(leaderboardRepositoryProvider),
  );
});

class GetLeaderboardParams {
  final String? scope;
  final String? collegeId;
  final int? page;
  final int? size;

  const GetLeaderboardParams({
    this.scope,
    this.collegeId,
    this.page,
    this.size,
  });
}

class GetLeaderboardUseCase
    implements UseCaseWithParams<LeaderboardEntity, GetLeaderboardParams> {
  final ILeaderboardRepository _repository;

  GetLeaderboardUseCase({required ILeaderboardRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, LeaderboardEntity>> call(GetLeaderboardParams params) {
    return _repository.getLeaderboard(
      scope: params.scope,
      collegeId: params.collegeId,
      page: params.page,
      size: params.size,
    );
  }
}
