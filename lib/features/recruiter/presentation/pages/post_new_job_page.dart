import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/features/companies/domain/entities/recruiter_workspace_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_workspace_entity.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:kaarya/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:kaarya/features/jobs/presentation/view_model/jobs_view_model.dart';
import 'package:kaarya/features/recruiter/presentation/pages/location_picker_page.dart';
import 'package:kaarya/features/recruiter/presentation/view_model/recruiter_view_model.dart';

class PostNewJobPage extends ConsumerStatefulWidget {
  const PostNewJobPage({super.key, this.jobId, this.job});

  final String? jobId;
  final JobDetailEntity? job;

  @override
  ConsumerState<PostNewJobPage> createState() => _PostNewJobPageState();
}

class _PostNewJobPageState extends ConsumerState<PostNewJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = HtmlEditorController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();

  String _employmentType = 'Full-Time';
  String _engagementType = 'Internship';
  String _workMode = 'onsite';
  DateTime? _deadline;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditMode => widget.jobId != null;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final isCollege = ref.read(isCollegeProvider);
      if (isCollege) {
        ref.read(collegeDashboardViewModelProvider.notifier).loadWorkspaces();
      } else {
        ref.read(recruiterViewModelProvider.notifier).loadWorkspaces();
      }
      _prefillFromJob();
    });
  }

  void _prefillFromJob() {
    final job = widget.job;
    if (job == null) return;
    _titleController.text = job.title;
    _locationController.text = job.location;
    _salaryController.text = job.salaryRange;
    _employmentType = job.employmentType;
    _engagementType = job.engagementType;
    _workMode = job.workMode.isEmpty ? 'onsite' : job.workMode;
    final d = DateTime.tryParse(job.deadline);
    if (d != null) _deadline = d;
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCollege = ref.watch(isCollegeProvider);
    final collegeState = ref.watch(collegeDashboardViewModelProvider);
    final recruiterState = ref.watch(recruiterViewModelProvider);

    final collegeWorkspace = collegeState.selectedWorkspace ?? collegeState.workspaces?.firstOrNull;
    final recruiterWorkspace = recruiterState.selectedWorkspace ?? recruiterState.workspaces?.firstOrNull;

    final workspace = isCollege ? collegeWorkspace : recruiterWorkspace;
    final displayName = workspace != null
        ? (workspace is CollegeWorkspaceEntity ? workspace.collegeName : (workspace as RecruiterWorkspaceEntity).companyName)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Job' : 'Post New Job'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (workspace != null && displayName != null) ...[
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Craft a high-quality role brief with structured hiring details for the selected workspace.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              MyTextFormField(
                controller: _titleController,
                text: 'Job Title',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Job title is required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Job Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 280,
                child: HtmlEditor(
                  controller: _descriptionController,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: 'Describe responsibilities, outcomes, and team expectations.',
                    initialText: widget.job?.description ?? '',
                  ),
                  otherOptions: const OtherOptions(
                    height: 260,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rich formatting is supported and will be shown in job details.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MyTextFormField(
                      controller: _locationController,
                      text: 'e.g. Kathmandu, Nepal',
                      optional: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Use zero-duration route to avoid WebView fade when popping back
                      // (flutter_inappwebview Hybrid Composition bug)
                      await Navigator.of(context).push(
                        PageRouteBuilder<void>(
                          pageBuilder: (_, __, ___) => LocationPickerPage(
                            initialAddress: _locationController.text,
                            onPicked: (address) {
                              _locationController.text = address;
                            },
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    icon: const Icon(Icons.map_outlined, size: 20),
                    label: const Text('Pick on map'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Employment Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _employmentType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: ['Full-Time', 'Part-Time', 'Contract', 'Freelance']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _employmentType = v ?? 'Full-Time'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Engagement Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _engagementType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: ['Internship', 'Project-Based', 'Consulting', 'Permanent']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _engagementType = v ?? 'Internship'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Work Mode',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _workMode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: ['remote', 'hybrid', 'onsite']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e == 'onsite' ? 'Onsite' : e == 'remote' ? 'Remote' : 'Hybrid'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _workMode = v ?? 'onsite'),
              ),
              const SizedBox(height: 20),
              MyTextFormField(
                controller: _salaryController,
                text: 'Salary Range (e.g. NPR 10,00,000 - NPR 18,00,000)',
                optional: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'Application Deadline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _deadline = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderStroke),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: AppColors.textMedium),
                      const SizedBox(width: 12),
                      Text(
                        _deadline != null
                            ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                            : 'Select deadline date',
                        style: TextStyle(
                          fontSize: 14,
                          color: _deadline != null ? AppColors.textDark : AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 14),
                ),
              ],
              const SizedBox(height: 32),
              MyButton(
                onPressed: _isSubmitting ? () {} : () => _submit(),
                text: _isSubmitting
                    ? (_isEditMode ? 'Saving...' : 'Creating...')
                    : (_isEditMode ? 'Save Changes' : 'Create Job Posting'),
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final description = (await _descriptionController.getText()).trim();
    if (description.isEmpty) {
      setState(() => _errorMessage = 'Description is required.');
      return;
    }
    final plainLength = description.replaceAll(RegExp(r'<[^>]*>'), '').trim().length;
    if (plainLength < 20) {
      setState(() => _errorMessage = 'Description must be at least 20 characters.');
      return;
    }

    if (_deadline == null) {
      setState(() => _errorMessage = 'Please select an application deadline.');
      return;
    }

    final isCollege = ref.read(isCollegeProvider);
    final collegeState = ref.read(collegeDashboardViewModelProvider);
    final recruiterState = ref.read(recruiterViewModelProvider);

    final collegeWorkspace = collegeState.selectedWorkspace ?? collegeState.workspaces?.firstOrNull;
    final recruiterWorkspace = recruiterState.selectedWorkspace ?? recruiterState.workspaces?.firstOrNull;

    final workspace = isCollege ? collegeWorkspace : recruiterWorkspace;
    if (workspace == null) {
      setState(() => _errorMessage = isCollege
          ? 'No college workspace. Contact support.'
          : 'No workspace selected. Please join a company first.');
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
      if (isCollege) 'collegeId': (workspace as CollegeWorkspaceEntity).collegeId,
      if (!isCollege) 'companyId': (workspace as RecruiterWorkspaceEntity).companyId,
      'title': _titleController.text.trim(),
      'description': description,
      'deadline': _deadline!.toIso8601String(),
      'status': _isEditMode && widget.job != null ? widget.job!.status : 'open',
      if (_locationController.text.trim().isNotEmpty)
        'location': _locationController.text.trim(),
      'employmentType': _employmentType,
      'engagementType': _engagementType,
      'workMode': _workMode,
      if (_salaryController.text.trim().isNotEmpty)
        'salaryRange': _salaryController.text.trim(),
      'requirements': <String, dynamic>{},
    };

    bool success = false;
    if (_isEditMode && widget.jobId != null) {
      final updated = await ref.read(jobsViewModelProvider.notifier).updateJob(widget.jobId!, payload);
      success = updated != null;
    } else {
      final created = await ref.read(jobsViewModelProvider.notifier).createJob(payload);
      success = created != null;
    }

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      SnackbarUtils.showSuccess(
        context,
        _isEditMode ? 'Job updated successfully!' : 'Job created successfully!',
      );
      if (isCollege) {
        ref.read(collegeDashboardViewModelProvider.notifier).loadCollegeJobs(
              collegeId: (workspace as CollegeWorkspaceEntity).collegeId,
              forceRefresh: true,
            );
      } else {
        ref.read(recruiterViewModelProvider.notifier).loadCompanyJobs(
              companyId: (workspace as RecruiterWorkspaceEntity).companyId,
              companyName: (workspace as RecruiterWorkspaceEntity).companyName,
              forceRefresh: true,
            );
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      setState(() => _errorMessage = _isEditMode
          ? 'Failed to update job. Please try again.'
          : 'Failed to create job. Please try again.');
    }
  }
}
