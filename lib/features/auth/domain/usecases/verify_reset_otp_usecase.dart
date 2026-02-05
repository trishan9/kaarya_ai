import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

class VerifyResetOtpParams extends Equatable {
  final String email;
  final String otp;
  const VerifyResetOtpParams({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}

final verifyResetOtpUseCaseProvider = Provider<VerifyResetOtpUseCase>((ref) {
  return VerifyResetOtpUseCase(
    authRepository: ref.read(authRepositoryProvider),
  );
});

class VerifyResetOtpUseCase
    implements UseCaseWithParams<String, VerifyResetOtpParams> {
  final IAuthRepository _authRepository;

  VerifyResetOtpUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, String>> call(VerifyResetOtpParams params) {
    return _authRepository.verifyPasswordResetOtp(params.email, params.otp);
  }
}
