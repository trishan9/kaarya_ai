import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/billing/data/repositories/billing_repository.dart';
import 'package:kaarya/features/billing/domain/repositories/billing_repository.dart';

final verifyStripeCheckoutSessionUseCaseProvider =
    Provider<VerifyStripeCheckoutSessionUseCase>((ref) {
      return VerifyStripeCheckoutSessionUseCase(
        ref.read(billingRepositoryProvider),
      );
    });

class VerifyStripeCheckoutSessionUseCaseParams extends Equatable {
  const VerifyStripeCheckoutSessionUseCaseParams({required this.sessionId});

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class VerifyStripeCheckoutSessionUseCase {
  VerifyStripeCheckoutSessionUseCase(this._repository);

  final IBillingRepository _repository;

  call(VerifyStripeCheckoutSessionUseCaseParams params) {
    return _repository.verifyStripeCheckoutSession(params.sessionId);
  }
}
