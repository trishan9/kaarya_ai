import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/auth/data/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/entities/linked_account_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';

final getLinkedAccountsUseCaseProvider = Provider<GetLinkedAccountsUseCase>((
  ref,
) {
  return GetLinkedAccountsUseCase(
    authRepository: ref.read(authRepositoryProvider),
  );
});

class GetLinkedAccountsUseCase
    implements UseCaseWithoutParams<List<LinkedAccountEntity>> {
  final IAuthRepository _authRepository;

  GetLinkedAccountsUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, List<LinkedAccountEntity>>> call() {
    return _authRepository.getLinkedAccounts();
  }
}
