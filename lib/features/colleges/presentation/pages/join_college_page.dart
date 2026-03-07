import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';

/// Page for candidates to join a college workspace via invite code.
/// No create feature - candidates can only join existing colleges.
class JoinCollegePage extends ConsumerStatefulWidget {
  const JoinCollegePage({super.key});

  @override
  ConsumerState<JoinCollegePage> createState() => _JoinCollegePageState();
}

class _JoinCollegePageState extends ConsumerState<JoinCollegePage> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final error = await ref.read(collegeDashboardViewModelProvider.notifier).joinWorkspace(
          inviteCode: _inviteCodeController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      SnackbarUtils.showError(context, error);
    } else {
      SnackbarUtils.showSuccess(context, 'Joined college workspace successfully');
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join College Workspace'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(50)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join a College',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enter the invite code shared by your college to access their job postings and leaderboard.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                MyTextFormField(
                  controller: _inviteCodeController,
                  text: 'Invite code (e.g. KR-AB12CD34)',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Invite code is required' : null,
                ),
                const SizedBox(height: 28),
                MyButton(
                  onPressed: _isSubmitting ? () {} : _submitJoin,
                  text: _isSubmitting ? 'Joining...' : 'Join College',
                  icon: const Icon(Icons.link, size: 18, color: Colors.white),
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
