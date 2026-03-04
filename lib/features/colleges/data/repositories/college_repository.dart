import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/colleges/data/datasources/college_datasource.dart';
import 'package:kaarya/features/colleges/data/datasources/local/college_local_datasource.dart';
import 'package:kaarya/features/colleges/data/datasources/remote/college_remote_datasource.dart';
import 'package:kaarya/features/colleges/data/models/college_hive_model.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_metrics_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_workspace_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/student_member_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final collegeRepositoryProvider = Provider<ICollegeRepository>((ref) {
  return CollegeRepository(
    remoteDatasource: ref.read(collegeRemoteDatasourceProvider),
    localDatasource: ref.read(collegeLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class CollegeRepository implements ICollegeRepository {
  final ICollegeRemoteDataSource _remoteDatasource;
  final ICollegeLocalDataSource _localDatasource;
  final NetworkInfo _networkInfo;

  CollegeRepository({
    required ICollegeRemoteDataSource remoteDatasource,
    required ICollegeLocalDataSource localDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<CollegeEntity>>> listColleges({
    int page = 1,
    int size = 20,
    String? search,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDatasource.listColleges(
          page: page,
          size: size,
          search: search,
        );
        await _localDatasource.saveColleges(
          remote.map(CollegeHiveModel.fromApiModel).toList(),
        );
        return Right(remote.map((e) => e.toEntity()).toList());
      } on DioException catch (e) {
        final cached = await _localDatasource.listColleges();
        if (cached.isNotEmpty) {
          return Right(cached.map((e) => e.toApiModel().toEntity()).toList());
        }
        return Left(
          _mapDioException(e, fallbackMessage: 'Failed to load colleges.'),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    final cached = await _localDatasource.listColleges();
    if (cached.isNotEmpty) {
      return Right(cached.map((e) => e.toApiModel().toEntity()).toList());
    }
    return const Left(
      NetworkFailure(message: 'No internet connection and no cached data.'),
    );
  }

  @override
  Future<Either<Failure, CollegeEntity>> getCollegeById(
    String collegeId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDatasource.getCollegeById(collegeId);
        await _localDatasource.saveCollege(
          CollegeHiveModel.fromApiModel(remote),
        );
        return Right(remote.toEntity());
      } on DioException catch (e) {
        final cached = await _localDatasource.getCollegeById(collegeId);
        if (cached != null) {
          return Right(cached.toApiModel().toEntity());
        }
        return Left(
          _mapDioException(
            e,
            fallbackMessage: 'Failed to load college details.',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    final cached = await _localDatasource.getCollegeById(collegeId);
    if (cached != null) {
      return Right(cached.toApiModel().toEntity());
    }
    return const Left(
      NetworkFailure(
        message: 'No internet connection and no cached college data.',
      ),
    );
  }

  @override
  Future<Either<Failure, CollegeEntity>> createCollege({
    required String name,
    required String institutionType,
    required String location,
    String? logoPath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to create college.'),
      );
    }

    try {
      final remote = await _remoteDatasource.createCollege(
        name: name,
        institutionType: institutionType,
        location: location,
        logoPath: logoPath,
      );
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to create college.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CollegeEntity>> updateCollege({
    required String collegeId,
    String? name,
    String? institutionType,
    String? location,
    String? logoPath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to update college.'),
      );
    }

    try {
      final remote = await _remoteDatasource.updateCollege(
        collegeId: collegeId,
        name: name,
        institutionType: institutionType,
        location: location,
        logoPath: logoPath,
      );
      await _localDatasource.saveCollege(CollegeHiveModel.fromApiModel(remote));
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to update college.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCollege(String collegeId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to delete college.'),
      );
    }

    try {
      final result = await _remoteDatasource.deleteCollege(collegeId);
      if (!result) {
        return const Left(ApiFailure(message: 'Unable to delete college.'));
      }
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to delete college.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CollegeEntity>> joinByCode(String inviteCode) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to join college.'),
      );
    }

    try {
      final remote = await _remoteDatasource.joinByCode(inviteCode);
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to join college.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetInviteCode(String collegeId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to reset invite code.'),
      );
    }

    try {
      final newCode = await _remoteDatasource.resetInviteCode(collegeId);
      return Right(newCode);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to reset invite code.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentMemberEntity>>> listStudents({
    required String collegeId,
    int page = 1,
    int size = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to load students.'),
      );
    }

    try {
      final remote = await _remoteDatasource.listStudents(
        collegeId: collegeId,
        page: page,
        size: size,
      );
      return Right(remote.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load students.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> inviteStudent({
    required String collegeId,
    required String email,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to invite student.'),
      );
    }

    try {
      final result = await _remoteDatasource.inviteStudent(
        collegeId: collegeId,
        email: email,
      );
      if (!result) {
        return const Left(ApiFailure(message: 'Unable to invite student.'));
      }
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to invite student.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeStudent({
    required String collegeId,
    required String studentId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to remove student.'),
      );
    }

    try {
      final result = await _remoteDatasource.removeStudent(
        collegeId: collegeId,
        studentId: studentId,
      );
      if (!result) {
        return const Left(ApiFailure(message: 'Unable to remove student.'));
      }
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to remove student.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CollegeWorkspaceEntity>>> listCollegeWorkspaces({
    int page = 1,
    int size = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to load workspaces.'),
      );
    }

    try {
      final remote = await _remoteDatasource.listCollegeWorkspaces(
        page: page,
        size: size,
      );
      return Right(remote.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load workspaces.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CollegeMetricsEntity>> getCollegeMetrics(
    String collegeId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to load metrics.'),
      );
    }

    try {
      final remote = await _remoteDatasource.getCollegeMetrics(collegeId);
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load college metrics.'),
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
