import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/jobs/presentation/pages/job_detail_page.dart';

/// Manage Job uses the same UI as Job Detail, with recruiter-specific bottom bar
/// (Manage Applicants, Back to Jobs).
class ManageJobPage extends ConsumerWidget {
  final String jobId;
  final String jobTitle;

  const ManageJobPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JobDetailPage(
      jobId: jobId,
      jobTitle: jobTitle,
      isRecruiterManageView: true,
    );
  }
}
