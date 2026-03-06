import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/billing/domain/usecases/create_stripe_checkout_session_usecase.dart';
import 'package:kaarya/features/billing/domain/usecases/create_stripe_portal_session_usecase.dart';
import 'package:kaarya/features/billing/domain/usecases/get_billing_summary_usecase.dart';
import 'package:kaarya/features/billing/domain/usecases/verify_stripe_checkout_session_usecase.dart';
import 'package:kaarya/features/billing/presentation/state/billing_state.dart';
import 'package:kaarya/features/billing/presentation/view_model/billing_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockGetBillingSummaryUseCase extends Mock
    implements GetBillingSummaryUseCase {}

class MockCreateStripeCheckoutSessionUseCase extends Mock
    implements CreateStripeCheckoutSessionUseCase {}

class MockCreateStripePortalSessionUseCase extends Mock
    implements CreateStripePortalSessionUseCase {}

class MockVerifyStripeCheckoutSessionUseCase extends Mock
    implements VerifyStripeCheckoutSessionUseCase {}

void main() {
  late MockGetBillingSummaryUseCase mockGetBillingSummaryUseCase;
  late MockCreateStripeCheckoutSessionUseCase
  mockCreateStripeCheckoutSessionUseCase;
  late MockCreateStripePortalSessionUseCase mockCreateStripePortalSessionUseCase;
  late MockVerifyStripeCheckoutSessionUseCase
  mockVerifyStripeCheckoutSessionUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const CreateStripeCheckoutSessionUseCaseParams(
        successPath: '/success',
        cancelPath: '/cancel',
      ),
    );
    registerFallbackValue(
      const CreateStripePortalSessionUseCaseParams(returnPath: '/billing'),
    );
    registerFallbackValue(
      const VerifyStripeCheckoutSessionUseCaseParams(sessionId: 'checkout-1'),
    );
  });

  setUp(() {
    mockGetBillingSummaryUseCase = MockGetBillingSummaryUseCase();
    mockCreateStripeCheckoutSessionUseCase =
        MockCreateStripeCheckoutSessionUseCase();
    mockCreateStripePortalSessionUseCase =
        MockCreateStripePortalSessionUseCase();
    mockVerifyStripeCheckoutSessionUseCase =
        MockVerifyStripeCheckoutSessionUseCase();

    container = ProviderContainer(
      overrides: [
        getBillingSummaryUseCaseProvider.overrideWithValue(
          mockGetBillingSummaryUseCase,
        ),
        createStripeCheckoutSessionUseCaseProvider.overrideWithValue(
          mockCreateStripeCheckoutSessionUseCase,
        ),
        createStripePortalSessionUseCaseProvider.overrideWithValue(
          mockCreateStripePortalSessionUseCase,
        ),
        verifyStripeCheckoutSessionUseCaseProvider.overrideWithValue(
          mockVerifyStripeCheckoutSessionUseCase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('BillingViewModel', () {
    test('should load summary successfully', () async {
      final summary = buildBillingSummaryEntity();
      when(
        () => mockGetBillingSummaryUseCase(),
      ).thenAnswer((_) async => Right(summary));

      final viewModel = container.read(billingViewModelProvider.notifier);
      await viewModel.loadSummary();

      final state = container.read(billingViewModelProvider);
      expect(state.summaryStatus, BillingLoadStatus.loaded);
      expect(state.summary, summary);
      expect(state.summaryErrorMessage, isNull);
    });

    test('should set error when summary loading fails', () async {
      const failure = ApiFailure(message: 'Unable to load summary');
      when(
        () => mockGetBillingSummaryUseCase(),
      ).thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(billingViewModelProvider.notifier);
      await viewModel.loadSummary();

      final state = container.read(billingViewModelProvider);
      expect(state.summaryStatus, BillingLoadStatus.error);
      expect(state.summaryErrorMessage, 'Unable to load summary');
    });

    test('should skip summary reload when data already exists', () async {
      final summary = buildBillingSummaryEntity();
      when(
        () => mockGetBillingSummaryUseCase(),
      ).thenAnswer((_) async => Right(summary));

      final viewModel = container.read(billingViewModelProvider.notifier);
      await viewModel.loadSummary();
      await viewModel.loadSummary();

      verify(() => mockGetBillingSummaryUseCase()).called(1);
    });

    test('should create checkout session', () async {
      final session = buildStripeCheckoutSessionEntity();
      when(
        () => mockCreateStripeCheckoutSessionUseCase(any()),
      ).thenAnswer((_) async => Right(session));

      final viewModel = container.read(billingViewModelProvider.notifier);
      final (result, failure) = await viewModel.createCheckoutSession();

      expect(result, session);
      expect(failure, isNull);
      expect(
        container.read(billingViewModelProvider).isStartingCheckout,
        isFalse,
      );
    });

    test('should return checkout failure', () async {
      const failure = ApiFailure(message: 'Checkout failed');
      when(
        () => mockCreateStripeCheckoutSessionUseCase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(billingViewModelProvider.notifier);
      final (result, error) = await viewModel.createCheckoutSession();

      expect(result, isNull);
      expect(error, failure);
    });

    test('should create portal session', () async {
      final session = buildStripePortalSessionEntity();
      when(
        () => mockCreateStripePortalSessionUseCase(any()),
      ).thenAnswer((_) async => Right(session));

      final viewModel = container.read(billingViewModelProvider.notifier);
      final (result, failure) = await viewModel.createPortalSession();

      expect(result, session);
      expect(failure, isNull);
      expect(
        container.read(billingViewModelProvider).isOpeningPortal,
        isFalse,
      );
    });

    test('should verify checkout session and refresh summary', () async {
      final verification = buildStripeCheckoutVerificationEntity();
      final summary = buildBillingSummaryEntity();
      when(
        () => mockVerifyStripeCheckoutSessionUseCase(any()),
      ).thenAnswer((_) async => Right(verification));
      when(
        () => mockGetBillingSummaryUseCase(),
      ).thenAnswer((_) async => Right(summary));

      final viewModel = container.read(billingViewModelProvider.notifier);
      final (result, failure) = await viewModel.verifyCheckoutSession(
        'checkout-1',
      );

      expect(result, verification);
      expect(failure, isNull);
      expect(container.read(billingViewModelProvider).summary, summary);
      expect(
        container.read(billingViewModelProvider).isVerifyingCheckout,
        isFalse,
      );
    });

    test('should return verification failure without refreshing summary', () async {
      const failure = ApiFailure(message: 'Verification failed');
      when(
        () => mockVerifyStripeCheckoutSessionUseCase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(billingViewModelProvider.notifier);
      final (result, error) = await viewModel.verifyCheckoutSession(
        'checkout-1',
      );

      expect(result, isNull);
      expect(error, failure);
      verifyNever(() => mockGetBillingSummaryUseCase());
    });
  });
}
