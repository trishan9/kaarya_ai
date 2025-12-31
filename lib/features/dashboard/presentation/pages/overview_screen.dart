import 'package:flutter/material.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/deadline_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/invitation_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/job_recommendation_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/summary_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/interview_readiness_chart_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/tips_banner_widget.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
      child: Column(
        spacing: 18,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCardWidget(),
          InvitationCardWidget(),
          DeadlineCardWidget(),
          InterviewReadinessChartWidget(),
          JobRecommendationWidget(),
          TipsBannerWidget(),
        ],
      ),
    );
  }
}
