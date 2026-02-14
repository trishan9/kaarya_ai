import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/resources/data/datasources/local/resource_local_datasource.dart';
import 'package:kaarya/features/resources/data/datasources/remote/resource_remote_datasource.dart';
import 'package:kaarya/features/resources/data/datasources/resource_datasource.dart';
import 'package:kaarya/features/resources/data/models/resource_course_hive_model.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';
import 'package:kaarya/features/resources/domain/repositories/resource_repository.dart';

final resourceRepositoryProvider = Provider<IResourceRepository>((ref) {
  return ResourceRepository(
    remoteDatasource: ref.read(resourceRemoteDatasourceProvider),
    localDatasource: ref.read(resourceLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ResourceRepository implements IResourceRepository {
  final IResourceRemoteDataSource _remoteDatasource;
  final IResourceLocalDataSource _localDatasource;
  final NetworkInfo _networkInfo;

  ResourceRepository({
    required IResourceRemoteDataSource remoteDatasource,
    required IResourceLocalDataSource localDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ResourceCoursesListEntity>> listCourses({
    int page = 1,
    int size = 20,
    String? search,
    String? difficulty,
    String? category,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDatasource.listCourses(
          page: page,
          size: size,
          search: search,
          difficulty: difficulty,
          category: category,
        );
        await _localDatasource.saveCoursesList(
          remote.courses.map(ResourceCourseHiveModel.fromApiModel).toList(),
        );
        return Right(
          ResourceCoursesListEntity(
            courses: remote.courses.map((e) => e.toEntity()).toList(),
            totalCount: remote.totalCount,
            page: remote.page,
            size: remote.size,
          ),
        );
      } on DioException catch (e) {
        final cached = await _localDatasource.listCourses();
        if (cached.isNotEmpty) {
          return Right(
            ResourceCoursesListEntity(
              courses: cached.map((e) => e.toApiModel().toEntity()).toList(),
              totalCount: cached.length,
              page: 1,
              size: cached.length,
            ),
          );
        }
        return Left(
          _mapDioException(e, fallbackMessage: 'Failed to load courses.'),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    final cached = await _localDatasource.listCourses();
    if (cached.isNotEmpty) {
      return Right(
        ResourceCoursesListEntity(
          courses: cached.map((e) => e.toApiModel().toEntity()).toList(),
          totalCount: cached.length,
          page: 1,
          size: cached.length,
        ),
      );
    }

    return const Left(
      NetworkFailure(
        message: 'No internet connection and no cached resources data.',
      ),
    );
  }

  @override
  Future<Either<Failure, ResourceCourseEntity>> getCourseById(
    String courseId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDatasource.getCourseById(courseId);
        await _localDatasource.saveCourse(
          ResourceCourseHiveModel.fromApiModel(remote),
        );
        return Right(remote.toEntity());
      } on DioException catch (e) {
        final cached = await _localDatasource.getCourseById(courseId);
        if (cached != null) {
          return Right(cached.toApiModel().toEntity());
        }
        return Left(
          _mapDioException(
            e,
            fallbackMessage: 'Failed to load course details.',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    final cached = await _localDatasource.getCourseById(courseId);
    if (cached != null) {
      return Right(cached.toApiModel().toEntity());
    }

    return const Left(
      NetworkFailure(
        message: 'No internet connection and no cached course data.',
      ),
    );
  }

  @override
  Future<Either<Failure, ResourceCourseEntity>> createCourse({
    required String title,
    String? description,
    required String category,
    required String generationMode,
    required String difficulty,
    required List<String> targetRoles,
    int? chapterCount,
    String? visibility,
    bool? includeVideoRecommendations,
    String? promptContext,
    String? jobDescriptionContext,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to create course.'),
      );
    }

    try {
      final remote = await _remoteDatasource.createCourse(
        title: title,
        description: description,
        category: category,
        generationMode: generationMode,
        difficulty: difficulty,
        targetRoles: targetRoles,
        chapterCount: chapterCount,
        visibility: visibility,
        includeVideoRecommendations: includeVideoRecommendations,
        promptContext: promptContext,
        jobDescriptionContext: jobDescriptionContext,
      );
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to create course.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ResourceCourseEntity>> updateCourse({
    required String courseId,
    required Map<String, dynamic> fields,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to update course.'),
      );
    }

    try {
      final remote = await _remoteDatasource.updateCourse(
        courseId: courseId,
        fields: fields,
      );
      await _localDatasource.saveCourse(
        ResourceCourseHiveModel.fromApiModel(remote),
      );
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to update course.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCourse(String courseId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to delete course.'),
      );
    }

    try {
      final result = await _remoteDatasource.deleteCourse(courseId);
      if (!result) {
        return const Left(ApiFailure(message: 'Unable to delete course.'));
      }
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to delete course.'),
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
