import 'package:kaarya/features/billing/data/models/billing_api_model.dart';

abstract interface class IBillingRemoteDataSource {
  Future<BillingSummaryApiModel> getBillingSummary();

  Future<StripeCheckoutSessionApiModel> createStripeCheckoutSession({
    required String successPath,
    required String cancelPath,
  });

  Future<StripePortalSessionApiModel> createStripePortalSession({
    required String returnPath,
  });

  Future<StripeCheckoutVerificationApiModel> verifyStripeCheckoutSession(
    String sessionId,
  );
}
