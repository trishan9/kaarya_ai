import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/config/billing_config.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/workspace_settings_widgets.dart';
import 'package:kaarya/features/billing/domain/entities/billing_summary_entity.dart';
import 'package:kaarya/features/billing/presentation/pages/stripe_webview_page.dart';
import 'package:kaarya/features/billing/presentation/state/billing_state.dart';
import 'package:kaarya/features/billing/presentation/view_model/billing_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BillingPage extends ConsumerStatefulWidget {
  const BillingPage({super.key});

  @override
  ConsumerState<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends ConsumerState<BillingPage> {
  static const _billingReturnPath = '/payment/checkout';
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_NP',
    symbol: 'NPR ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(billingViewModelProvider.notifier).loadSummary(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRecruiter = ref.watch(isRecruiterProvider);
    final isCollege = ref.watch(isCollegeProvider);
    final state = ref.watch(billingViewModelProvider);
    final summary = state.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(billingViewModelProvider.notifier)
              .loadSummary(forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: isRecruiter || isCollege
                    ? _buildIneligibleState(context)
                    : _buildCandidateContent(context, state, summary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIneligibleState(BuildContext context) {
    return const WorkspaceSettingsSection(
      title: 'Full Access Enabled',
      description:
          'Billing upgrade is not required for recruiter or college accounts in the current release.',
      child: WorkspaceEmptyState(
        icon: LucideIcons.shieldCheck,
        title: 'No billing action needed',
        description:
            'This account already has access to all currently available workspace features.',
      ),
    );
  }

  Widget _buildCandidateContent(
    BuildContext context,
    BillingState state,
    BillingSummaryEntity? summary,
  ) {
    if (state.summaryStatus == BillingLoadStatus.loading && summary == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.summaryStatus == BillingLoadStatus.error && summary == null) {
      return WorkspaceSettingsSection(
        title: 'Billing unavailable',
        description:
            state.summaryErrorMessage ??
            'We could not load your billing summary.',
        child: WorkspaceEmptyState(
          icon: LucideIcons.receiptText,
          title: 'Unable to load billing',
          description:
              'Check your connection and try again. Billing uses your live Stripe-backed account state.',
          action: SizedBox(
            width: 220,
            child: MyButton(
              onPressed: () => ref
                  .read(billingViewModelProvider.notifier)
                  .loadSummary(forceRefresh: true),
              text: 'Retry',
            ),
          ),
        ),
      );
    }

    final safeSummary =
        summary ??
        BillingSummaryEntity(
          currentPlan: 'free',
          currentPlanLabel: 'Free',
          currentPlanPriceNpr: 0,
          nextPlan: 'pro',
          nextPlanLabel: 'Pro',
          nextPlanPriceNpr: BillingConfig.proMonthlyPriceNpr,
          canUpgrade: true,
          currency: 'NPR',
          usage: const BillingUsageEntity(
            month: 'Current',
            interviewsUsed: 0,
            interviewsRemaining: BillingConfig.freeMonthlyInterviewLimit,
          ),
          limits: const BillingLimitsEntity(
            monthlyInterviewLimit: BillingConfig.freeMonthlyInterviewLimit,
          ),
          plans: const [],
          invoices: const [],
        );

    final isCompact = MediaQuery.of(context).size.width < 860;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.summaryErrorMessage != null &&
            state.summaryStatus == BillingLoadStatus.error)
          _InlineMessage(
            text: state.summaryErrorMessage!,
            color: AppColors.warning,
            background: AppColors.bgLightOrange,
          ),
        _BillingHeroCard(summary: safeSummary, currency: _currency),
        const SizedBox(height: 18),
        if (isCompact) ...[
          _buildPlanOverview(context, safeSummary),
          const SizedBox(height: 18),
          _buildBillingAction(context, state, safeSummary),
          const SizedBox(height: 18),
          _buildInvoiceSection(context, state),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildPlanOverview(context, safeSummary),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildBillingAction(context, state, safeSummary),
                    const SizedBox(height: 18),
                    _buildInvoiceSection(context, state),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPlanOverview(
    BuildContext context,
    BillingSummaryEntity summary,
  ) {
    final usageLimit = summary.limits.monthlyInterviewLimit;
    final usageProgress = usageLimit == null || usageLimit == 0
        ? 1.0
        : (summary.usage.interviewsUsed / usageLimit)
              .clamp(0.0, 1.0)
              .toDouble();

    return WorkspaceSettingsSection(
      title: 'Plan Overview',
      description: 'Current plan and monthly interview usage.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BillingInfoTile(
            eyebrow: 'CURRENT PLAN',
            child: Row(
              children: [
                _PlanBadge(
                  label: summary.currentPlanLabel,
                  isPrimary: summary.isPro,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_currency.format(summary.currentPlanPriceNpr)} / month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _BillingInfoTile(
            eyebrow: 'UPGRADE',
            child: Text(
              summary.canUpgrade
                  ? '${summary.nextPlanLabel ?? 'Pro'} - ${_currency.format(summary.nextPlanPriceNpr ?? BillingConfig.proMonthlyPriceNpr)} / month'
                  : 'Already on highest tier',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _BillingInfoTile(
            eyebrow: 'INTERVIEW USAGE THIS MONTH',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Interview usage this month',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      summary.usage.month,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: usageProgress,
                    minHeight: 8,
                    backgroundColor: AppColors.bgSecondary,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  usageLimit == null
                      ? '${summary.usage.interviewsUsed} used, unlimited on Pro'
                      : '${summary.usage.interviewsUsed} of $usageLimit used (${summary.usage.interviewsRemaining ?? 0} remaining)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _BillingFeatureList(),
        ],
      ),
    );
  }

  Widget _buildBillingAction(
    BuildContext context,
    BillingState state,
    BillingSummaryEntity summary,
  ) {
    final subtotal = summary.canUpgrade
        ? summary.nextPlanPriceNpr ?? BillingConfig.proMonthlyPriceNpr
        : 0;
    final total = subtotal + BillingConfig.taxNpr;

    return WorkspaceSettingsSection(
      title: 'Billing Action',
      description: summary.canUpgrade
          ? 'Complete checkout in Stripe.'
          : 'Manage billing in Stripe customer portal.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: Column(
              children: [
                _AmountRow(
                  label: 'Subtotal',
                  value: _currency.format(subtotal),
                ),
                const SizedBox(height: 12),
                _AmountRow(
                  label: 'Tax',
                  value: _currency.format(BillingConfig.taxNpr),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: AppColors.borderStroke),
                ),
                _AmountRow(
                  label: 'Total',
                  value: _currency.format(total),
                  emphasize: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MyButton(
            onPressed: state.isStartingCheckout || state.isOpeningPortal
                ? () {}
                : () => summary.canUpgrade ? _startCheckout() : _openPortal(),
            text: summary.canUpgrade
                ? 'Pay with Stripe'
                : 'Manage Billing in Stripe',
            isLoading: summary.canUpgrade
                ? state.isStartingCheckout || state.isVerifyingCheckout
                : state.isOpeningPortal,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection(BuildContext context, BillingState state) {
    return WorkspaceSettingsSection(
      title: 'Invoices In Stripe',
      description:
          'Invoice history and downloadable bills are managed directly in Stripe portal.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderStroke,
                style: BorderStyle.solid,
              ),
            ),
            child: Text(
              'Open Stripe portal to view invoice history, download receipts, and manage payment methods.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          MyButton(
            onPressed: state.isOpeningPortal ? () {} : _openPortal,
            text: 'Manage Billing in Stripe',
            variant: ButtonVariant.secondary,
            isLoading: state.isOpeningPortal,
          ),
        ],
      ),
    );
  }

  Future<void> _startCheckout() async {
    final vm = ref.read(billingViewModelProvider.notifier);
    final (session, failure) = await vm.createCheckoutSession();
    if (!mounted) return;

    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }
    if (session == null) {
      SnackbarUtils.showError(
        context,
        'Unable to create Stripe checkout session.',
      );
      return;
    }

    final result = await Navigator.of(context).push<StripeFlowResult>(
      MaterialPageRoute(
        builder: (_) => StripeWebViewPage(
          initialUrl: session.checkoutUrl,
          interceptPath: _billingReturnPath,
          title: 'Stripe Checkout',
        ),
      ),
    );

    if (!mounted || result == null) return;

    if (result.cancelled) {
      SnackbarUtils.showInfo(
        context,
        'Stripe checkout was cancelled. No charge was applied.',
      );
      return;
    }

    if (result.hasSessionId) {
      final (verification, verifyFailure) = await vm.verifyCheckoutSession(
        result.sessionId!,
      );
      if (!mounted) return;

      if (verifyFailure != null) {
        SnackbarUtils.showError(
          context,
          'Payment completed, but verification failed: ${verifyFailure.message}',
        );
        return;
      }

      SnackbarUtils.showSuccess(
        context,
        verification?.invoiceNumber != null
            ? 'Payment verified. Invoice: ${verification!.invoiceNumber}'
            : 'Payment verified. Pro plan is active now.',
      );
    }
  }

  Future<void> _openPortal() async {
    final vm = ref.read(billingViewModelProvider.notifier);
    final (session, failure) = await vm.createPortalSession();
    if (!mounted) return;

    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }
    if (session == null) {
      SnackbarUtils.showError(context, 'Unable to open Stripe billing portal.');
      return;
    }

    await Navigator.of(context).push<StripeFlowResult>(
      MaterialPageRoute(
        builder: (_) => StripeWebViewPage(
          initialUrl: session.portalUrl,
          interceptPath: _billingReturnPath,
          title: 'Stripe Billing',
        ),
      ),
    );

    if (!mounted) return;
    await vm.loadSummary(forceRefresh: true);
  }
}

class _BillingHeroCard extends StatelessWidget {
  const _BillingHeroCard({required this.summary, required this.currency});

  final BillingSummaryEntity summary;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final title = summary.isPro
        ? 'Manage your Pro billing in Stripe'
        : 'Upgrade to Pro with Stripe';
    final description = summary.isPro
        ? 'Use one place to manage billing, view invoices, and keep your Pro access active.'
        : 'Unlock unlimited interview practice and manage checkout through Stripe.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2783BE), Color(0xFF00629F)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -8,
            child: Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -28,
            child: Container(
              width: 220,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 680;
                  final children = [
                    _HeroMetric(
                      label: 'Account',
                      value: summary.currentPlanLabel,
                    ),
                    _HeroMetric(
                      label: 'Monthly Price',
                      value: currency.format(summary.currentPlanPriceNpr),
                    ),
                    _HeroMetric(
                      label: 'Usage Month',
                      value: summary.usage.month,
                    ),
                    _HeroMetric(
                      label: 'Interviews Used',
                      value: '${summary.usage.interviewsUsed}',
                    ),
                  ];

                  if (compact) {
                    return Column(
                      children: children
                          .map(
                            (child) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: child,
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Row(
                    children: children
                        .map(
                          (child) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: child,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillingInfoTile extends StatelessWidget {
  const _BillingInfoTile({required this.eyebrow, required this.child});

  final String eyebrow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textLight,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BillingFeatureList extends StatelessWidget {
  const _BillingFeatureList();

  @override
  Widget build(BuildContext context) {
    final items = const [
      'Unlimited interview sessions',
      'Priority AI feedback flow',
      'Stripe-hosted billing management',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What Pro includes',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    LucideIcons.circleCheckBig,
                    size: 18,
                    color: AppColors.success2,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
            if (item != items.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textDark,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.label, required this.isPrimary});

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFE7F6EC) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isPrimary ? const Color(0xFF4CAF50) : AppColors.borderStroke,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isPrimary ? const Color(0xFF1E9A50) : AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.text,
    required this.color,
    required this.background,
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}
