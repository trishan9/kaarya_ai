import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/deadline_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/invitation_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/job_filter_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/job_recommendation_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/overlapping_avatars_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/rating_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/summary_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/tips_banner_widget.dart';
import 'package:kaarya/features/onboarding/presentation/widgets/onboarding_progress_widget.dart';
import 'package:kaarya/features/recruiter/presentation/widgets/recruiter_job_card_widget.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('DeadlineCardWidget should show empty state when no job is provided', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget(const DeadlineCardWidget(job: null)));

    expect(find.text('Deadline Today!'), findsOneWidget);
    expect(find.text('No upcoming deadlines'), findsOneWidget);
  });

  testWidgets('InvitationCardWidget should show fallback invitation copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      createTestWidget(const InvitationCardWidget(invitation: null)),
    );

    expect(find.text('No pending invitations'), findsOneWidget);
    expect(find.text('No interviews scheduled yet'), findsOneWidget);
  });

  testWidgets('JobFilterWidget should emit selected filter', (tester) async {
    JobFilter? selected;

    await tester.pumpWidget(
      createTestWidget(
        JobFilterWidget(
          selectedFilter: JobFilter.forYou,
          onChanged: (value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.text('Trending Jobs'));
    await tester.pump();

    expect(selected, JobFilter.trending);
  });

  testWidgets('JobRecommendationWidget should switch filters', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        JobRecommendationWidget(
          jobsBucket: buildJobsBucketEntity(),
        ),
      ),
    );

    expect(find.text('AI Engineer'), findsOneWidget);

    await tester.tap(find.text('Trending Jobs'));
    await tester.pump();

    expect(find.text('Software Engineer'), findsOneWidget);
  });

  testWidgets('RatingCardWidget should clamp rating and handle action tap', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      createTestWidget(
        RatingCardWidget(
          title: 'Profile Rating',
          rating: 120,
          badgeLabel: 'Excellent',
          description: 'Your profile is strong.',
          suggestionTitle: 'Tip',
          suggestionBody: 'Add more projects.',
          actionLabel: 'Improve',
          onActionTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('100%'), findsOneWidget);
    await tester.tap(find.text('Improve'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('SummaryCardWidget should update application count when filter changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      createTestWidget(
        SummaryCardWidget(summary: buildDashboardOverviewEntity().summary),
      ),
    );

    expect(find.text('124'), findsOneWidget);

    await tester.tap(find.textContaining('Applied'));
    await tester.pump();

    expect(find.text('50'), findsOneWidget);
  });

  testWidgets('TipsBannerWidget should show static banner copy', (tester) async {
    await tester.pumpWidget(createTestWidget(const TipsBannerWidget()));

    expect(find.textContaining("We've got some tips"), findsOneWidget);
  });

  testWidgets('OverlappingAvatars should render extra count badge', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        const OverlappingAvatars(avatars: [], extraCount: 3),
      ),
    );

    expect(find.text('+3'), findsOneWidget);
  });

  testWidgets('OnboardingProgress should highlight active step', (tester) async {
    await tester.pumpWidget(
      createTestWidget(const OnboardingProgress(index: 2)),
    );

    expect(find.byKey(const ValueKey('bar_2')), findsOneWidget);
  });

  testWidgets('RecruiterJobCardWidget should show recruiter job summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      createTestWidget(
        RecruiterJobCardWidget(job: buildJobEntity()),
      ),
    );

    expect(find.text('AI Engineer'), findsOneWidget);
    expect(find.text('Manage Job'), findsOneWidget);
  });
}
