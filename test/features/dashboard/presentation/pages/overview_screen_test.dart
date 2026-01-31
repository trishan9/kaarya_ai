import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/features/dashboard/presentation/pages/overview_screen.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/deadline_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/interview_readiness_chart_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/invitation_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/job_recommendation_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/summary_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/tips_banner_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget() {
    return const MaterialApp(home: Scaffold(body: OverviewScreen()));
  }

  group('OverviewScreen - UI Elements', () {
    testWidgets('should render all overview sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(OverviewScreen), findsOneWidget);
      expect(find.byType(SummaryCardWidget), findsOneWidget);
      expect(find.byType(InvitationCardWidget), findsOneWidget);
      expect(find.byType(DeadlineCardWidget), findsOneWidget);
      expect(find.byType(InterviewReadinessChartWidget), findsOneWidget);
      expect(find.byType(JobRecommendationWidget), findsOneWidget);
      expect(find.byType(TipsBannerWidget), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('OverviewScreen - Interactions', () {
    testWidgets('should update summary count when status filter changes', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('124'), findsOneWidget);

      await tester.tap(find.text('Mock Interviews'));
      await tester.pumpAndSettle();

      expect(find.text('18'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should update job list when job filter changes', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Job Recommendations'));

      expect(find.text('AI Engineer'), findsOneWidget);
      expect(find.text('Software Engineer'), findsOneWidget);

      await tester.tap(find.text('Trending Jobs'));
      await tester.pumpAndSettle();

      expect(find.text('Software Engineer'), findsOneWidget);
      expect(find.text('AI Engineer'), findsNothing);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
