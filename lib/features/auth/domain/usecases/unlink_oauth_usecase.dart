import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

class UnlinkOAuthParams extends Equatable {
  final String provider;
  const UnlinkOAuthParams({required this.provider});
  @override
  List<Object?> get props => [provider];
}

final unlinkOAuthUseCaseProvider = Provider<UnlinkOAuthUseCase>((ref) {
  return UnlinkOAuthUseCase(authRepository: ref.read(authRepositoryProvider));
});

class UnlinkOAuthUseCase implements UseCaseWithParams<bool, UnlinkOAuthParams> {
  final IAuthRepository _authRepository;

  UnlinkOAuthUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(UnlinkOAuthParams params) {
    return _authRepository.unlinkOAuth(params.provider);
  }
}
