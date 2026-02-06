import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/bookmarks/data/datasources/bookmark_datasource.dart';
import 'package:kaarya/features/bookmarks/data/datasources/local/bookmark_local_datasource.dart';
import 'package:kaarya/features/bookmarks/data/datasources/remote/bookmark_remote_datasource.dart';
import 'package:kaarya/features/bookmarks/data/models/bookmark_hive_model.dart';
import 'package:kaarya/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:kaarya/features/bookmarks/domain/repositories/bookmark_repository.dart';

final bookmarkRepositoryProvider = Provider<IBookmarkRepository>((ref) {
  return BookmarkRepository(
    remoteDatasource: ref.read(bookmarkRemoteDatasourceProvider),
    localDatasource: ref.read(bookmarkLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class BookmarkRepository implements IBookmarkRepository {
  final IBookmarkRemoteDataSource _remoteDatasource;
  final IBookmarkLocalDataSource _localDatasource;
  final NetworkInfo _networkInfo;

  BookmarkRepository({
    required IBookmarkRemoteDataSource remoteDatasource,
    required IBookmarkLocalDataSource localDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, BookmarksListEntity>> getMyBookmarks({
    String? type,
    String? search,
    String? sortBy,
    int? page,
    int? size,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final data = await _remoteDatasource.getMyBookmarks(
          type: type,
          search: search,
          sortBy: sortBy,
          page: page,
          size: size,
        );
        await _localDatasource.saveMyBookmarks(
          BookmarksHiveModel.fromApiModel(data),
        );
        return Right(data.toEntity());
      } on DioException catch (e) {
        final cached = await _localDatasource.getMyBookmarks();
        if (cached != null) return Right(cached.toApiModel().toEntity());
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Failed to load bookmarks',
          ),
        );
      } catch (e) {
        final cached = await _localDatasource.getMyBookmarks();
        if (cached != null) return Right(cached.toApiModel().toEntity());
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = await _localDatasource.getMyBookmarks();
      if (cached != null) return Right(cached.toApiModel().toEntity());
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveJobBookmark(String jobId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remoteDatasource.saveJobBookmark(jobId);
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to save bookmark',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unsaveJobBookmark(String jobId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remoteDatasource.unsaveJobBookmark(jobId);
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to remove bookmark',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveInterviewBookmark(
    String interviewId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remoteDatasource.saveInterviewBookmark(interviewId);
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to save bookmark',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unsaveInterviewBookmark(
    String interviewId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remoteDatasource.unsaveInterviewBookmark(interviewId);
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to remove bookmark',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
