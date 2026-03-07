import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:kaarya/features/dashboard/data/datasources/local/dashboard_local_datasource.dart';
import 'package:kaarya/features/dashboard/data/datasources/remote/dashboard_remote_datasource.dart';
import 'package:kaarya/features/dashboard/data/models/dashboard_overview_hive_model.dart';
import 'package:kaarya/features/dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:kaarya/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  final remoteDatasource = ref.read(dashboardRemoteDatasourceProvider);
  final localDatasource = ref.read(dashboardLocalDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return DashboardRepository(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
    networkInfo: networkInfo,
  );
});

class DashboardRepository implements IDashboardRepository {
  final IDashboardRemoteDataSource _remoteDatasource;
  final IDashboardLocalDataSource _localDatasource;
  final NetworkInfo _networkInfo;

  DashboardRepository({
    required IDashboardRemoteDataSource remoteDatasource,
    required IDashboardLocalDataSource localDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _networkInfo = networkInfo;

  @override
  Future<DashboardOverviewEntity?> getOverviewFromCache({
    String? monthKey,
  }) async {
    final cached = await _localDatasource.getOverviewData(
      monthKey: monthKey,
    );
    return cached?.toApiModel().toEntity();
  }

  @override
  Future<Either<Failure, DashboardOverviewEntity>> getOverviewData({
    String? monthKey,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDatasource.getOverviewData(
          monthKey: monthKey,
        );
        await _localDatasource.saveOverviewData(
          DashboardOverviewHiveModel.fromApiModel(
            remote,
            monthKey: monthKey ?? 'default',
          ),
        );
        return Right(remote.toEntity());
      } on DioException catch (e) {
        final cached = await _localDatasource.getOverviewData(
          monthKey: monthKey,
        );
        if (cached != null) {
          return Right(cached.toApiModel().toEntity());
        }

        return Left(
          _mapDioException(e, fallbackMessage: 'Failed to load overview.'),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    final cached = await _localDatasource.getOverviewData(monthKey: monthKey);
    if (cached != null) {
      return Right(cached.toApiModel().toEntity());
    }

    return const Left(
      NetworkFailure(
        message: 'No internet connection and no cached overview data.',
      ),
    );
  }

  @override
  Future<Either<Failure, ProfilePreferences>> getProfilePreferences() async {
    try {
      final data = await _remoteDatasource.getProfilePreferences();
      return Right(
        ProfilePreferences(
          defaultResumeId: data.defaultResumeId,
          portfolioLinks: data.portfolioLinks,
          linkedinUrl: data.linkedinUrl,
          githubUrl: data.githubUrl,
          portfolioUrl: data.portfolioUrl,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure(message: e.message ?? 'Failed to load preferences'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Failure _mapDioException(DioException e, {required String fallbackMessage}) {
    final data = e.response?.data;
    String? message;

    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    }

    return ApiFailure(
      statusCode: e.response?.statusCode,
      message: message ?? e.message ?? fallbackMessage,
    );
  }
}
