import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

class ExchangeOAuthResultUseCaseParams extends Equatable {
  const ExchangeOAuthResultUseCaseParams({required this.resultToken});

  final String resultToken;

  @override
  List<Object?> get props => [resultToken];
}

final exchangeOAuthResultUseCaseProvider = Provider<ExchangeOAuthResultUseCase>(
  (ref) {
    final authRepository = ref.read(authRepositoryProvider);
    return ExchangeOAuthResultUseCase(authRepository: authRepository);
  },
);

class ExchangeOAuthResultUseCase
    implements UseCaseWithParams<AuthEntity, ExchangeOAuthResultUseCaseParams> {
  ExchangeOAuthResultUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(
    ExchangeOAuthResultUseCaseParams params,
  ) {
    return _authRepository.exchangeOAuthResult(params.resultToken);
  }
}
