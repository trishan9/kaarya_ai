import 'package:equatable/equatable.dart';
import 'package:kaarya/features/billing/domain/entities/billing_summary_entity.dart';

enum BillingLoadStatus { initial, loading, loaded, error }

class BillingState extends Equatable {
  static const Object _unset = Object();

  const BillingState({
    this.summaryStatus = BillingLoadStatus.initial,
    this.summary,
    this.summaryErrorMessage,
    this.isStartingCheckout = false,
    this.isOpeningPortal = false,
    this.isVerifyingCheckout = false,
  });

  final BillingLoadStatus summaryStatus;
  final BillingSummaryEntity? summary;
  final String? summaryErrorMessage;
  final bool isStartingCheckout;
  final bool isOpeningPortal;
  final bool isVerifyingCheckout;

  BillingState copyWith({
    BillingLoadStatus? summaryStatus,
    Object? summary = _unset,
    Object? summaryErrorMessage = _unset,
    bool? isStartingCheckout,
    bool? isOpeningPortal,
    bool? isVerifyingCheckout,
  }) {
    return BillingState(
      summaryStatus: summaryStatus ?? this.summaryStatus,
      summary: summary == _unset
          ? this.summary
          : summary as BillingSummaryEntity?,
      summaryErrorMessage: summaryErrorMessage == _unset
          ? this.summaryErrorMessage
          : summaryErrorMessage as String?,
      isStartingCheckout: isStartingCheckout ?? this.isStartingCheckout,
      isOpeningPortal: isOpeningPortal ?? this.isOpeningPortal,
      isVerifyingCheckout: isVerifyingCheckout ?? this.isVerifyingCheckout,
    );
  }

  @override
  List<Object?> get props => [
    summaryStatus,
    summary,
    summaryErrorMessage,
    isStartingCheckout,
    isOpeningPortal,
    isVerifyingCheckout,
  ];
}
