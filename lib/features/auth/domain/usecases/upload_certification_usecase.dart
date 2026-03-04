import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

class UploadCertificationParams extends Equatable {
  final String filePath;
  const UploadCertificationParams({required this.filePath});
  @override
  List<Object?> get props => [filePath];
}

final uploadCertificationUseCaseProvider = Provider<UploadCertificationUseCase>(
  (ref) {
    return UploadCertificationUseCase(
      authRepository: ref.read(authRepositoryProvider),
    );
  },
);

class UploadCertificationUseCase
    implements UseCaseWithParams<String, UploadCertificationParams> {
  final IAuthRepository _authRepository;

  UploadCertificationUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, String>> call(UploadCertificationParams params) {
    return _authRepository.uploadCertification(params.filePath);
  }
}
