import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/billing/domain/entities/billing_summary_entity.dart';

abstract interface class IBillingRepository {
  Future<Either<Failure, BillingSummaryEntity>> getBillingSummary();

  Future<Either<Failure, StripeCheckoutSessionEntity>>
  createStripeCheckoutSession({
    required String successPath,
    required String cancelPath,
  });

  Future<Either<Failure, StripePortalSessionEntity>> createStripePortalSession({
    required String returnPath,
  });

  Future<Either<Failure, StripeCheckoutVerificationEntity>>
  verifyStripeCheckoutSession(String sessionId);
}
