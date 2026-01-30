import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> registerUser(AuthEntity user);
  Future<Either<Failure, AuthEntity>> loginUser(String email, String password);
  Future<Either<Failure, bool>> logoutUser();
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, AuthEntity>> updateProfile(AuthEntity user);
}
