import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUsecaseParams extends Equatable {
  final String? name;
  final String? email;
  final File? photo;

  const UpdateProfileUsecaseParams({this.name, this.email, this.photo});

  @override
  List<Object?> get props => [name, email, photo];
}

final updateProfileUseCaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UpdateProfileUsecase(authRepository: authRepository);
});

class UpdateProfileUsecase
    implements UseCaseWithParams<AuthEntity, UpdateProfileUsecaseParams> {
  final IAuthRepository _authRepository;

  UpdateProfileUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateProfileUsecaseParams params) {
    return _authRepository.updateProfile(
      params.name,
      params.email,
      params.photo,
    );
  }
}
