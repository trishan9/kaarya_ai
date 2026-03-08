import 'package:equatable/equatable.dart';

class BillingPlanSnapshotEntity extends Equatable {
  const BillingPlanSnapshotEntity({
    required this.id,
    required this.label,
    required this.monthlyPriceNpr,
    required this.monthlyInterviewLimit,
  });

  final String id;
  final String label;
  final int monthlyPriceNpr;
  final int? monthlyInterviewLimit;

  @override
  List<Object?> get props => [
    id,
    label,
    monthlyPriceNpr,
    monthlyInterviewLimit,
  ];
}

class BillingInvoiceEntity extends Equatable {
  const BillingInvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.transactionUuid,
    required this.amountNpr,
    required this.currency,
    required this.paymentProvider,
    required this.status,
    required this.planFrom,
    required this.planTo,
    required this.issuedAt,
    required this.paidAt,
  });

  final String id;
  final String invoiceNumber;
  final String transactionUuid;
  final int amountNpr;
  final String currency;
  final String paymentProvider;
  final String status;
  final String planFrom;
  final String planTo;
  final DateTime? issuedAt;
  final DateTime? paidAt;

  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    transactionUuid,
    amountNpr,
    currency,
    paymentProvider,
    status,
    planFrom,
    planTo,
    issuedAt,
    paidAt,
  ];
}

class BillingUsageEntity extends Equatable {
  const BillingUsageEntity({
    required this.month,
    required this.interviewsUsed,
    required this.interviewsRemaining,
  });

  final String month;
  final int interviewsUsed;
  final int? interviewsRemaining;

  @override
  List<Object?> get props => [month, interviewsUsed, interviewsRemaining];
}

class BillingLimitsEntity extends Equatable {
  const BillingLimitsEntity({required this.monthlyInterviewLimit});

  final int? monthlyInterviewLimit;

  @override
  List<Object?> get props => [monthlyInterviewLimit];
}

class BillingSummaryEntity extends Equatable {
  const BillingSummaryEntity({
    required this.currentPlan,
    required this.currentPlanLabel,
    required this.currentPlanPriceNpr,
    required this.nextPlan,
    required this.nextPlanLabel,
    required this.nextPlanPriceNpr,
    required this.canUpgrade,
    required this.currency,
    required this.usage,
    required this.limits,
    required this.plans,
    required this.invoices,
  });

  final String currentPlan;
  final String currentPlanLabel;
  final int currentPlanPriceNpr;
  final String? nextPlan;
  final String? nextPlanLabel;
  final int? nextPlanPriceNpr;
  final bool canUpgrade;
  final String currency;
  final BillingUsageEntity usage;
  final BillingLimitsEntity limits;
  final List<BillingPlanSnapshotEntity> plans;
  final List<BillingInvoiceEntity> invoices;

  bool get isPro => currentPlan.toLowerCase() == 'pro';

  @override
  List<Object?> get props => [
    currentPlan,
    currentPlanLabel,
    currentPlanPriceNpr,
    nextPlan,
    nextPlanLabel,
    nextPlanPriceNpr,
    canUpgrade,
    currency,
    usage,
    limits,
    plans,
    invoices,
  ];
}

class StripeCheckoutSessionEntity extends Equatable {
  const StripeCheckoutSessionEntity({
    required this.sessionId,
    required this.checkoutUrl,
    required this.currency,
    required this.amountNpr,
    required this.plan,
  });

  final String sessionId;
  final String checkoutUrl;
  final String currency;
  final int amountNpr;
  final String plan;

  @override
  List<Object?> get props => [
    sessionId,
    checkoutUrl,
    currency,
    amountNpr,
    plan,
  ];
}

class StripePortalSessionEntity extends Equatable {
  const StripePortalSessionEntity({required this.portalUrl});

  final String portalUrl;

  @override
  List<Object?> get props => [portalUrl];
}

class StripeCheckoutVerificationEntity extends Equatable {
  const StripeCheckoutVerificationEntity({
    required this.plan,
    required this.unlocked,
    required this.sessionId,
    required this.invoiceNumber,
    required this.amountNpr,
    required this.currency,
  });

  final String plan;
  final bool unlocked;
  final String sessionId;
  final String? invoiceNumber;
  final int amountNpr;
  final String currency;

  @override
  List<Object?> get props => [
    plan,
    unlocked,
    sessionId,
    invoiceNumber,
    amountNpr,
    currency,
  ];
}
