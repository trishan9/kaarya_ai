import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/leaderboard/data/datasources/leaderboard_datasource.dart';
import 'package:kaarya/features/leaderboard/data/datasources/local/leaderboard_local_datasource.dart';
import 'package:kaarya/features/leaderboard/data/datasources/remote/leaderboard_remote_datasource.dart';
import 'package:kaarya/features/leaderboard/data/models/leaderboard_hive_model.dart';
import 'package:kaarya/features/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:kaarya/features/leaderboard/domain/repositories/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<ILeaderboardRepository>((ref) {
  return LeaderboardRepository(
    remoteDatasource: ref.read(leaderboardRemoteDatasourceProvider),
    localDatasource: ref.read(leaderboardLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class LeaderboardRepository implements ILeaderboardRepository {
  final ILeaderboardRemoteDataSource _remoteDatasource;
  final ILeaderboardLocalDataSource _localDatasource;
  final NetworkInfo _networkInfo;

  LeaderboardRepository({
    required ILeaderboardRemoteDataSource remoteDatasource,
    required ILeaderboardLocalDataSource localDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, LeaderboardEntity>> getLeaderboard({
    String? scope,
    String? collegeId,
    int? page,
    int? size,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final data = await _remoteDatasource.getLeaderboard(
          scope: scope,
          collegeId: collegeId,
          page: page,
          size: size,
        );
        await _localDatasource.saveLeaderboard(
          LeaderboardHiveModel.fromApiModel(data),
        );
        return Right(data.toEntity());
      } on DioException catch (e) {
        final cached = await _localDatasource.getLeaderboard();
        if (cached != null) return Right(cached.toApiModel().toEntity());
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data['message'] ?? 'Failed to load leaderboard',
          ),
        );
      } catch (e) {
        final cached = await _localDatasource.getLeaderboard();
        if (cached != null) return Right(cached.toApiModel().toEntity());
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = await _localDatasource.getLeaderboard();
      if (cached != null) return Right(cached.toApiModel().toEntity());
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
