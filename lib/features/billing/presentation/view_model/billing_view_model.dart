import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/billing/domain/entities/billing_summary_entity.dart';
import 'package:kaarya/features/billing/domain/usecases/create_stripe_checkout_session_usecase.dart';
import 'package:kaarya/features/billing/domain/usecases/create_stripe_portal_session_usecase.dart';
import 'package:kaarya/features/billing/domain/usecases/get_billing_summary_usecase.dart';
import 'package:kaarya/features/billing/domain/usecases/verify_stripe_checkout_session_usecase.dart';
import 'package:kaarya/features/billing/presentation/state/billing_state.dart';

final billingViewModelProvider =
    NotifierProvider<BillingViewModel, BillingState>(BillingViewModel.new);

class BillingViewModel extends Notifier<BillingState> {
  late final GetBillingSummaryUseCase _getBillingSummaryUseCase;
  late final CreateStripeCheckoutSessionUseCase
  _createStripeCheckoutSessionUseCase;
  late final CreateStripePortalSessionUseCase _createStripePortalSessionUseCase;
  late final VerifyStripeCheckoutSessionUseCase
  _verifyStripeCheckoutSessionUseCase;

  @override
  BillingState build() {
    _getBillingSummaryUseCase = ref.read(getBillingSummaryUseCaseProvider);
    _createStripeCheckoutSessionUseCase = ref.read(
      createStripeCheckoutSessionUseCaseProvider,
    );
    _createStripePortalSessionUseCase = ref.read(
      createStripePortalSessionUseCaseProvider,
    );
    _verifyStripeCheckoutSessionUseCase = ref.read(
      verifyStripeCheckoutSessionUseCaseProvider,
    );
    return const BillingState();
  }

  Future<void> loadSummary({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        state.summaryStatus == BillingLoadStatus.loaded &&
        state.summary != null) {
      return;
    }

    state = state.copyWith(
      summaryStatus: BillingLoadStatus.loading,
      summaryErrorMessage: null,
    );

    final result = await _getBillingSummaryUseCase();
    result.fold(
      (failure) => state = state.copyWith(
        summaryStatus: BillingLoadStatus.error,
        summaryErrorMessage: failure.message,
      ),
      (summary) => state = state.copyWith(
        summaryStatus: BillingLoadStatus.loaded,
        summary: summary,
        summaryErrorMessage: null,
      ),
    );
  }

  Future<(StripeCheckoutSessionEntity?, Failure?)>
  createCheckoutSession() async {
    state = state.copyWith(isStartingCheckout: true);

    final result = await _createStripeCheckoutSessionUseCase(
      const CreateStripeCheckoutSessionUseCaseParams(
        successPath: '/payment/checkout',
        cancelPath: '/payment/checkout',
      ),
    );

    state = state.copyWith(isStartingCheckout: false);
    return result.fold(
      (failure) => (null, failure),
      (session) => (session, null),
    );
  }

  Future<(StripePortalSessionEntity?, Failure?)> createPortalSession() async {
    state = state.copyWith(isOpeningPortal: true);

    final result = await _createStripePortalSessionUseCase(
      const CreateStripePortalSessionUseCaseParams(
        returnPath: '/payment/checkout',
      ),
    );

    state = state.copyWith(isOpeningPortal: false);
    return result.fold(
      (failure) => (null, failure),
      (session) => (session, null),
    );
  }

  Future<(StripeCheckoutVerificationEntity?, Failure?)> verifyCheckoutSession(
    String sessionId,
  ) async {
    state = state.copyWith(isVerifyingCheckout: true);

    final result = await _verifyStripeCheckoutSessionUseCase(
      VerifyStripeCheckoutSessionUseCaseParams(sessionId: sessionId),
    );

    if (result.isLeft()) {
      final failure = result.swap().getOrElse(
        () => const ApiFailure(message: 'Payment verification failed.'),
      );
      state = state.copyWith(isVerifyingCheckout: false);
      final Failure typedFailure = failure;
      return (null, typedFailure);
    }

    final verification = result.getOrElse(
      () => throw StateError('Expected Stripe verification response.'),
    );
    await loadSummary(forceRefresh: true);
    state = state.copyWith(isVerifyingCheckout: false);
    final StripeCheckoutVerificationEntity typedVerification = verification;
    return (typedVerification, null);
  }
}
