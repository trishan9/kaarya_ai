import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/billing/data/repositories/billing_repository.dart';
import 'package:kaarya/features/billing/domain/repositories/billing_repository.dart';
import 'package:kaarya/features/billing/domain/usecases/create_stripe_checkout_session_usecase.dart';
import 'package:kaarya/features/billing/domain/usecases/create_stripe_portal_session_usecase.dart';
import 'package:kaarya/features/billing/domain/usecases/get_billing_summary_usecase.dart';
import 'package:kaarya/features/billing/domain/usecases/verify_stripe_checkout_session_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockBillingRepository extends Mock implements IBillingRepository {}

void main() {
  late MockBillingRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockBillingRepository();
    container = ProviderContainer(
      overrides: [
        billingRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Billing usecase providers', () {
    test('should resolve billing usecases from provider', () {
      expect(container.read(getBillingSummaryUseCaseProvider), isA<GetBillingSummaryUseCase>());
      expect(
        container.read(createStripeCheckoutSessionUseCaseProvider),
        isA<CreateStripeCheckoutSessionUseCase>(),
      );
      expect(
        container.read(createStripePortalSessionUseCaseProvider),
        isA<CreateStripePortalSessionUseCase>(),
      );
      expect(
        container.read(verifyStripeCheckoutSessionUseCaseProvider),
        isA<VerifyStripeCheckoutSessionUseCase>(),
      );
    });
  });

  group('GetBillingSummaryUseCase', () {
    test('should return repository summary', () async {
      final expected = buildBillingSummaryEntity();
      when(() => mockRepository.getBillingSummary()).thenAnswer(
        (_) async => Right(expected),
      );

      final usecase = GetBillingSummaryUseCase(mockRepository);
      final result = await usecase();

      expect(result, Right(expected));
      verify(() => mockRepository.getBillingSummary()).called(1);
    });
  });

  group('CreateStripeCheckoutSessionUseCase', () {
    test('should pass success and cancel paths to repository', () async {
      final expected = buildStripeCheckoutSessionEntity();
      when(
        () => mockRepository.createStripeCheckoutSession(
          successPath: any(named: 'successPath'),
          cancelPath: any(named: 'cancelPath'),
        ),
      ).thenAnswer((_) async => Right(expected));

      final usecase = CreateStripeCheckoutSessionUseCase(mockRepository);
      const params = CreateStripeCheckoutSessionUseCaseParams(
        successPath: '/success',
        cancelPath: '/cancel',
      );
      final result = await usecase(params);

      expect(result, Right(expected));
      verify(
        () => mockRepository.createStripeCheckoutSession(
          successPath: '/success',
          cancelPath: '/cancel',
        ),
      ).called(1);
      expect(params.props, ['/success', '/cancel']);
    });
  });

  group('CreateStripePortalSessionUseCase', () {
    test('should pass return path to repository', () async {
      final expected = buildStripePortalSessionEntity();
      when(
        () => mockRepository.createStripePortalSession(
          returnPath: any(named: 'returnPath'),
        ),
      ).thenAnswer((_) async => Right(expected));

      final usecase = CreateStripePortalSessionUseCase(mockRepository);
      const params = CreateStripePortalSessionUseCaseParams(
        returnPath: '/billing',
      );
      final result = await usecase(params);

      expect(result, Right(expected));
      verify(
        () => mockRepository.createStripePortalSession(returnPath: '/billing'),
      ).called(1);
      expect(params.props, ['/billing']);
    });
  });

  group('VerifyStripeCheckoutSessionUseCase', () {
    test('should pass session id to repository', () async {
      final expected = buildStripeCheckoutVerificationEntity();
      when(
        () => mockRepository.verifyStripeCheckoutSession(any()),
      ).thenAnswer((_) async => Right(expected));

      final usecase = VerifyStripeCheckoutSessionUseCase(mockRepository);
      const params = VerifyStripeCheckoutSessionUseCaseParams(
        sessionId: 'checkout-1',
      );
      final result = await usecase(params);

      expect(result, Right(expected));
      verify(
        () => mockRepository.verifyStripeCheckoutSession('checkout-1'),
      ).called(1);
      expect(params.props, ['checkout-1']);
    });

    test('should return repository failure', () async {
      const failure = ApiFailure(message: 'Verification failed');
      when(
        () => mockRepository.verifyStripeCheckoutSession(any()),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = VerifyStripeCheckoutSessionUseCase(mockRepository);
      final result = await usecase(
        const VerifyStripeCheckoutSessionUseCaseParams(sessionId: 'checkout-1'),
      );

      expect(result, const Left(failure));
    });
  });
}
