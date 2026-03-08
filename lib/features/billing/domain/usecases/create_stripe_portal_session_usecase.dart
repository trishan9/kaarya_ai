import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/billing/data/repositories/billing_repository.dart';
import 'package:kaarya/features/billing/domain/repositories/billing_repository.dart';

final createStripePortalSessionUseCaseProvider =
    Provider<CreateStripePortalSessionUseCase>((ref) {
      return CreateStripePortalSessionUseCase(
        ref.read(billingRepositoryProvider),
      );
    });

class CreateStripePortalSessionUseCaseParams extends Equatable {
  const CreateStripePortalSessionUseCaseParams({required this.returnPath});

  final String returnPath;

  @override
  List<Object?> get props => [returnPath];
}

class CreateStripePortalSessionUseCase {
  CreateStripePortalSessionUseCase(this._repository);

  final IBillingRepository _repository;

  call(CreateStripePortalSessionUseCaseParams params) {
    return _repository.createStripePortalSession(returnPath: params.returnPath);
  }
}
