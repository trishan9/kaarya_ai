import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

class LoginWithGoogleUseCaseParams extends Equatable {
  const LoginWithGoogleUseCaseParams({required this.serverClientId});

  final String serverClientId;

  @override
  List<Object?> get props => [serverClientId];
}

final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginWithGoogleUseCase(authRepository: authRepository);
});

class LoginWithGoogleUseCase
    implements UseCaseWithParams<AuthEntity, LoginWithGoogleUseCaseParams> {
  LoginWithGoogleUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(
    LoginWithGoogleUseCaseParams params,
  ) {
    return _authRepository.loginWithGoogle(params.serverClientId);
  }
}
