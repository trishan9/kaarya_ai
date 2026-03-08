import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/entities/oauth_provider_status_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

class GetOAuthProviderStatusParams extends Equatable {
  const GetOAuthProviderStatusParams({required this.provider});

  final String provider;

  @override
  List<Object?> get props => [provider];
}

final getOAuthProviderStatusUseCaseProvider =
    Provider<GetOAuthProviderStatusUseCase>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return GetOAuthProviderStatusUseCase(authRepository: authRepository);
    });

class GetOAuthProviderStatusUseCase
    implements
        UseCaseWithParams<
          OAuthProviderStatusEntity,
          GetOAuthProviderStatusParams
        > {
  GetOAuthProviderStatusUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  @override
  Future<Either<Failure, OAuthProviderStatusEntity>> call(
    GetOAuthProviderStatusParams params,
  ) {
    return _authRepository.getOAuthProviderStatus(params.provider);
  }
}
