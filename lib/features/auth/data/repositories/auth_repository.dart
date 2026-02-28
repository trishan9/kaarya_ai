import 'dart:io';

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
import 'package:kaarya/features/auth/domain/entities/linked_account_entity.dart';
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
  Future<Either<Failure, AuthEntity>> updateProfile(
    String? name,
    String? email,
    File? photo,
    Map<String, dynamic>? candidateProfile,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final userModel = await _authRemoteDataSource.updateProfile(
          name,
          email,
          photo,
          candidateProfile,
        );

        if (userModel != null) {
          final userEntity = userModel.toEntity();
          return Right(userEntity);
        }

        return const Left(ApiFailure(message: "Failed to update profile!"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Failed to update profile!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(
          message:
              "You need to be connected to internet, to perform this action!",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.changePassword(
          currentPassword,
          newPassword,
          confirmNewPassword,
        );
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data['message'] ?? "Failed to change password!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: "Internet connection required to change password.",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> requestPasswordReset(String email) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.requestPasswordReset(email);
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data['message'] ??
                "Failed to request password reset!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: "Internet connection required to reset password.",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> verifyPasswordResetOtp(
    String email,
    String otp,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final token = await _authRemoteDataSource.verifyPasswordResetOtp(
          email,
          otp,
        );
        return Right(token);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Failed to verify OTP!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        NetworkFailure(message: "Internet connection required to verify OTP."),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> confirmPasswordReset(
    String token,
    String password,
    String confirmPassword,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.confirmPasswordReset(
          token,
          password,
          confirmPassword,
        );
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Failed to reset password!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: "Internet connection required to reset password.",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<LinkedAccountEntity>>> getLinkedAccounts() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _authRemoteDataSource.getLinkedAccounts();
        final entities = models.map((m) => m.toEntity()).toList();
        return Right(entities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data['message'] ?? "Failed to get linked accounts!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: "Internet connection required to get linked accounts.",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> unlinkOAuth(String provider) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.unlinkOAuth(provider);
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Failed to unlink account!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: "Internet connection required to unlink account.",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadCertification(String filePath) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _authRemoteDataSource.uploadCertification(filePath);
        return Right(url);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data['message'] ??
                "Failed to upload certification!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: "Internet connection required to upload certification.",
        ),
      );
    }
  }
}
