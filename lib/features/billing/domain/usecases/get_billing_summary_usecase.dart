import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/billing/data/repositories/billing_repository.dart';
import 'package:kaarya/features/billing/domain/repositories/billing_repository.dart';

final getBillingSummaryUseCaseProvider = Provider<GetBillingSummaryUseCase>((
  ref,
) {
  return GetBillingSummaryUseCase(ref.read(billingRepositoryProvider));
});

class GetBillingSummaryUseCase {
  GetBillingSummaryUseCase(this._repository);

  final IBillingRepository _repository;

  call() {
    return _repository.getBillingSummary();
  }
}
