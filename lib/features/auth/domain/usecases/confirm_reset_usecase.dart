import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

class ConfirmResetParams extends Equatable {
  final String token;
  final String password;
  const ConfirmResetParams({required this.token, required this.password});
  @override
  List<Object?> get props => [token, password];
}

final confirmResetUseCaseProvider = Provider<ConfirmResetUseCase>((ref) {
  return ConfirmResetUseCase(authRepository: ref.read(authRepositoryProvider));
});

class ConfirmResetUseCase
    implements UseCaseWithParams<bool, ConfirmResetParams> {
  final IAuthRepository _authRepository;

  ConfirmResetUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ConfirmResetParams params) {
    return _authRepository.confirmPasswordReset(params.token, params.password);
  }
}
