import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/auth/data/datasources/auth_datasource.dart';
import 'package:kaarya/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:kaarya/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kaarya/features/auth/data/models/auth_api_model.dart';
import 'package:kaarya/features/auth/data/models/auth_hive_model.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AuthRepository(
    authLocalDatasource: authLocalDatasource,
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authLocalDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authLocalDatasource,
    required IAuthRemoteDataSource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authLocalDataSource = authLocalDatasource,
       _authRemoteDataSource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> registerUser(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final userModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.registerUser(userModel);

        return Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Failed to register user!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final existingUser = await _authLocalDataSource.getUserByEmail(
          user.email!,
        );

        if (existingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: "This email has already been used!"),
          );
        }

        final userModel = AuthHiveModel.fromEntity(user);
        await _authLocalDataSource.registerUser(userModel);

        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginUser(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final userModel = await _authRemoteDataSource.loginUser(
          email,
          password,
        );

        if (userModel != null) {
          final entity = userModel.toEntity();
          return Right(entity);
        }

        return const Left(
          ApiFailure(message: "Email or password is incorrect!"),
        );
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Failed to login user!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authLocalDataSource.loginUser(email, password);

        if (user != null) {
          final userEntity = user.toEntity();
          return Right(userEntity);
        }

        return const Left(
          LocalDatabaseFailure(
            message: "Your email or password is incorrect, please try again!",
          ),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    if (await _networkInfo.isConnected) {
      try {
        final userModel = await _authRemoteDataSource.getCurrentUser();

        if (userModel != null) {
          final userEntity = userModel.toEntity();
          return Right(userEntity);
        }

        return const Left(
          ApiFailure(message: "No any user is logged in currently!"),
        );
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data['message'] ?? "Failed to get current user!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authLocalDataSource.getCurrentUser();

        if (user != null) {
          final userEntity = user.toEntity();
          return Right(userEntity);
        }

        return const Left(
          LocalDatabaseFailure(message: "No any user is logged in currently!"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logoutUser() async {
    if (await _networkInfo.isConnected) {
      try {
        final loggedOut = await _authRemoteDataSource.logoutUser();
        if (loggedOut) {
          return const Right(true);
        }

        return const Left(ApiFailure(message: "Failed to logout user!"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Failed to logout user!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final loggedOut = await _authLocalDataSource.logoutUser();
        if (loggedOut) {
          return const Right(true);
        }

        return const Left(LocalDatabaseFailure(message: "Unable to logout!"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      throw UnimplementedError();
    } else {
      try {
        final userPayloadModel = AuthHiveModel.fromEntity(user);

        final userModel = await _authLocalDataSource.updateProfile(
          userPayloadModel,
        );

        if (userModel != null) {
          final entity = userModel.toEntity();
          return Right(entity);
        }

        return const Left(
          LocalDatabaseFailure(message: "Unable to update profile!"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
