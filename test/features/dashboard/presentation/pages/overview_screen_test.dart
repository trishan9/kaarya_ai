import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/features/dashboard/presentation/pages/overview_screen.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/deadline_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/interview_readiness_chart_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/invitation_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/job_recommendation_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/summary_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/tips_banner_widget.dart';

import '../../../../helpers/test_fixtures.dart';

class TestDashboardViewModel extends DashboardViewModel {
  @override
  DashboardState build() {
    return DashboardState(
      overviewStatus: DashboardLoadStatus.loaded,
      overviewData: buildDashboardOverviewEntity(),
    );
  }

  @override
  Future<void> loadOverview({String? monthKey, bool forceRefresh = false}) async {
    state = state.copyWith(
      overviewStatus: DashboardLoadStatus.loaded,
      overviewData: buildDashboardOverviewEntity(),
      overviewMonthKey: monthKey ?? state.overviewMonthKey,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        dashboardViewModelProvider.overrideWith(TestDashboardViewModel.new),
      ],
      child: const MaterialApp(home: Scaffold(body: OverviewScreen())),
    );
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
}
