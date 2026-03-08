import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/billing/domain/entities/billing_summary_entity.dart';

class BillingPlanSnapshotApiModel {
  const BillingPlanSnapshotApiModel({
    required this.id,
    required this.label,
    required this.monthlyPriceNpr,
    required this.monthlyInterviewLimit,
  });

  final String id;
  final String label;
  final int monthlyPriceNpr;
  final int? monthlyInterviewLimit;

  factory BillingPlanSnapshotApiModel.fromJson(Map<String, dynamic> json) {
    return BillingPlanSnapshotApiModel(
      id: jsonString(json['id']),
      label: jsonString(json['label']),
      monthlyPriceNpr: jsonInt(json['monthlyPriceNpr']),
      monthlyInterviewLimit: json['monthlyInterviewLimit'] == null
          ? null
          : jsonInt(json['monthlyInterviewLimit']),
    );
  }

  BillingPlanSnapshotEntity toEntity() {
    return BillingPlanSnapshotEntity(
      id: id,
      label: label,
      monthlyPriceNpr: monthlyPriceNpr,
      monthlyInterviewLimit: monthlyInterviewLimit,
    );
  }
}

class BillingInvoiceApiModel {
  const BillingInvoiceApiModel({
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

  factory BillingInvoiceApiModel.fromJson(Map<String, dynamic> json) {
    return BillingInvoiceApiModel(
      id: jsonString(json['id']),
      invoiceNumber: jsonString(json['invoiceNumber']),
      transactionUuid: jsonString(json['transactionUuid']),
      amountNpr: jsonInt(json['amountNpr']),
      currency: jsonString(json['currency'], fallback: 'NPR'),
      paymentProvider: jsonString(json['paymentProvider']),
      status: jsonString(json['status']),
      planFrom: jsonString(json['planFrom']),
      planTo: jsonString(json['planTo']),
      issuedAt: _parseDate(json['issuedAt']),
      paidAt: _parseDate(json['paidAt']),
    );
  }

  BillingInvoiceEntity toEntity() {
    return BillingInvoiceEntity(
      id: id,
      invoiceNumber: invoiceNumber,
      transactionUuid: transactionUuid,
      amountNpr: amountNpr,
      currency: currency,
      paymentProvider: paymentProvider,
      status: status,
      planFrom: planFrom,
      planTo: planTo,
      issuedAt: issuedAt,
      paidAt: paidAt,
    );
  }
}

class BillingUsageApiModel {
  const BillingUsageApiModel({
    required this.month,
    required this.interviewsUsed,
    required this.interviewsRemaining,
  });

  final String month;
  final int interviewsUsed;
  final int? interviewsRemaining;

  factory BillingUsageApiModel.fromJson(Map<String, dynamic> json) {
    return BillingUsageApiModel(
      month: jsonString(json['month']),
      interviewsUsed: jsonInt(json['interviewsUsed']),
      interviewsRemaining: json['interviewsRemaining'] == null
          ? null
          : jsonInt(json['interviewsRemaining']),
    );
  }

  BillingUsageEntity toEntity() {
    return BillingUsageEntity(
      month: month,
      interviewsUsed: interviewsUsed,
      interviewsRemaining: interviewsRemaining,
    );
  }
}

class BillingLimitsApiModel {
  const BillingLimitsApiModel({required this.monthlyInterviewLimit});

  final int? monthlyInterviewLimit;

  factory BillingLimitsApiModel.fromJson(Map<String, dynamic> json) {
    return BillingLimitsApiModel(
      monthlyInterviewLimit: json['monthlyInterviewLimit'] == null
          ? null
          : jsonInt(json['monthlyInterviewLimit']),
    );
  }

  BillingLimitsEntity toEntity() {
    return BillingLimitsEntity(monthlyInterviewLimit: monthlyInterviewLimit);
  }
}

class BillingSummaryApiModel {
  const BillingSummaryApiModel({
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
  final BillingUsageApiModel usage;
  final BillingLimitsApiModel limits;
  final List<BillingPlanSnapshotApiModel> plans;
  final List<BillingInvoiceApiModel> invoices;

  factory BillingSummaryApiModel.fromJson(Map<String, dynamic> json) {
    return BillingSummaryApiModel(
      currentPlan: jsonString(json['currentPlan'], fallback: 'free'),
      currentPlanLabel: jsonString(json['currentPlanLabel'], fallback: 'Free'),
      currentPlanPriceNpr: jsonInt(json['currentPlanPriceNpr']),
      nextPlan: jsonNullableString(json['nextPlan']),
      nextPlanLabel: jsonNullableString(json['nextPlanLabel']),
      nextPlanPriceNpr: json['nextPlanPriceNpr'] == null
          ? null
          : jsonInt(json['nextPlanPriceNpr']),
      canUpgrade: jsonBool(json['canUpgrade']),
      currency: jsonString(json['currency'], fallback: 'NPR'),
      usage: BillingUsageApiModel.fromJson(
        jsonAsMap(json['usage']) ?? const <String, dynamic>{},
      ),
      limits: BillingLimitsApiModel.fromJson(
        jsonAsMap(json['limits']) ?? const <String, dynamic>{},
      ),
      plans: jsonAsList(
        json['plans'],
      ).map(BillingPlanSnapshotApiModel.fromJson).toList(),
      invoices: jsonAsList(
        json['invoices'],
      ).map(BillingInvoiceApiModel.fromJson).toList(),
    );
  }

  BillingSummaryEntity toEntity() {
    return BillingSummaryEntity(
      currentPlan: currentPlan,
      currentPlanLabel: currentPlanLabel,
      currentPlanPriceNpr: currentPlanPriceNpr,
      nextPlan: nextPlan,
      nextPlanLabel: nextPlanLabel,
      nextPlanPriceNpr: nextPlanPriceNpr,
      canUpgrade: canUpgrade,
      currency: currency,
      usage: usage.toEntity(),
      limits: limits.toEntity(),
      plans: plans.map((item) => item.toEntity()).toList(),
      invoices: invoices.map((item) => item.toEntity()).toList(),
    );
  }
}

class StripeCheckoutSessionApiModel {
  const StripeCheckoutSessionApiModel({
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

  factory StripeCheckoutSessionApiModel.fromJson(Map<String, dynamic> json) {
    return StripeCheckoutSessionApiModel(
      sessionId: jsonString(json['sessionId']),
      checkoutUrl: jsonString(json['checkoutUrl']),
      currency: jsonString(json['currency'], fallback: 'NPR'),
      amountNpr: jsonInt(json['amountNpr']),
      plan: jsonString(json['plan'], fallback: 'pro'),
    );
  }

  StripeCheckoutSessionEntity toEntity() {
    return StripeCheckoutSessionEntity(
      sessionId: sessionId,
      checkoutUrl: checkoutUrl,
      currency: currency,
      amountNpr: amountNpr,
      plan: plan,
    );
  }
}

class StripePortalSessionApiModel {
  const StripePortalSessionApiModel({required this.portalUrl});

  final String portalUrl;

  factory StripePortalSessionApiModel.fromJson(Map<String, dynamic> json) {
    return StripePortalSessionApiModel(
      portalUrl: jsonString(json['portalUrl']),
    );
  }

  StripePortalSessionEntity toEntity() {
    return StripePortalSessionEntity(portalUrl: portalUrl);
  }
}

class StripeCheckoutVerificationApiModel {
  const StripeCheckoutVerificationApiModel({
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

  factory StripeCheckoutVerificationApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StripeCheckoutVerificationApiModel(
      plan: jsonString(json['plan'], fallback: 'pro'),
      unlocked: jsonBool(json['unlocked']),
      sessionId: jsonString(json['sessionId']),
      invoiceNumber: jsonNullableString(json['invoiceNumber']),
      amountNpr: jsonInt(json['amountNpr']),
      currency: jsonString(json['currency'], fallback: 'NPR'),
    );
  }

  StripeCheckoutVerificationEntity toEntity() {
    return StripeCheckoutVerificationEntity(
      plan: plan,
      unlocked: unlocked,
      sessionId: sessionId,
      invoiceNumber: invoiceNumber,
      amountNpr: amountNpr,
      currency: currency,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  final text = jsonNullableString(value);
  if (text == null) return null;
  return DateTime.tryParse(text);
}
