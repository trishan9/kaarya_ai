import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/billing/data/repositories/billing_repository.dart';
import 'package:kaarya/features/billing/domain/repositories/billing_repository.dart';

final createStripeCheckoutSessionUseCaseProvider =
    Provider<CreateStripeCheckoutSessionUseCase>((ref) {
      return CreateStripeCheckoutSessionUseCase(
        ref.read(billingRepositoryProvider),
      );
    });

class CreateStripeCheckoutSessionUseCaseParams extends Equatable {
  const CreateStripeCheckoutSessionUseCaseParams({
    required this.successPath,
    required this.cancelPath,
  });

  final String successPath;
  final String cancelPath;

  @override
  List<Object?> get props => [successPath, cancelPath];
}

class CreateStripeCheckoutSessionUseCase {
  CreateStripeCheckoutSessionUseCase(this._repository);

  final IBillingRepository _repository;

  call(CreateStripeCheckoutSessionUseCaseParams params) {
    return _repository.createStripeCheckoutSession(
      successPath: params.successPath,
      cancelPath: params.cancelPath,
    );
  }
}
