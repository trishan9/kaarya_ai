import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/presentation/pages/create_interview_manual_page.dart';
import 'package:kaarya/features/interviews/presentation/pages/interview_detail_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Create Interview page – form-based creation only.
/// Used by: candidates (from AI Interview Hub), recruiters, and colleges (from Interview Management).
class CreateInterviewPage extends ConsumerWidget {
  const CreateInterviewPage({
    super.key,
    this.companyId,
    this.collegeId,
  });

  final String? companyId;
  final String? collegeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecruiter = ref.watch(isRecruiterProvider);
    final isCollege = ref.watch(isCollegeProvider);
    final isCandidate = !isRecruiter && !isCollege;

    void onCreated(InterviewEntity interview) {
      SnackbarUtils.showSuccess(context, 'Interview created successfully');
      final navigator = Navigator.of(context);
      navigator.pop();
      navigator.push(
        MaterialPageRoute(
          builder: (_) => InterviewDetailPage(interview: interview),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Interview'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => AppRoutes.pop(context),
        ),
      ),
      body: CreateInterviewManualPage(
        companyId: companyId,
        collegeId: collegeId,
        isRecruiter: isRecruiter,
        isCollege: isCollege,
        isCandidate: isCandidate,
        onCreated: onCreated,
      ),
    );
  }
}
