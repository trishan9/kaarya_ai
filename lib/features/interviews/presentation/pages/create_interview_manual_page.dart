import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/usecases/create_interview_usecase.dart';
import 'package:kaarya/features/interviews/presentation/view_model/create_interview_view_model.dart';
import 'package:kaarya/features/recruiter/presentation/view_model/recruiter_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CreateInterviewManualPage extends ConsumerStatefulWidget {
  const CreateInterviewManualPage({
    super.key,
    this.companyId,
    this.collegeId,
    required this.isRecruiter,
    required this.isCollege,
    required this.isCandidate,
    required this.onCreated,
  });

  final String? companyId;
  final String? collegeId;
  final bool isRecruiter;
  final bool isCollege;
  final bool isCandidate;
  final void Function(InterviewEntity) onCreated;

  @override
  ConsumerState<CreateInterviewManualPage> createState() =>
      _CreateInterviewManualPageState();
}

class _CreateInterviewManualPageState
    extends ConsumerState<CreateInterviewManualPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _roleController = TextEditingController();
  final _techStackController = TextEditingController();
  final _questionCountController = TextEditingController(text: '8');
  final _durationController = TextEditingController(text: '25');
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _interviewType = 'technical';
  String _experienceLevel = '';
  String _visibility = 'public';
  String _status = 'published';
  String? _selectedCompanyId;
  String? _selectedCollegeId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isRecruiter) {
        ref.read(recruiterViewModelProvider.notifier).loadWorkspaces();
      } else if (widget.isCollege) {
        ref.read(collegeDashboardViewModelProvider.notifier).loadWorkspaces();
      }
    });
    _selectedCompanyId = widget.companyId;
    _selectedCollegeId = widget.collegeId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roleController.dispose();
    _techStackController.dispose();
    _questionCountController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final companyId = widget.isRecruiter ? _selectedCompanyId : null;
    final collegeId = widget.isCollege ? _selectedCollegeId : null;

    final techStack = _techStackController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final questionCount = int.tryParse(_questionCountController.text) ?? 8;
    final durationMinutes = int.tryParse(_durationController.text) ?? 25;

    final params = CreateInterviewUseCaseParams(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      interviewType: _interviewType,
      role: _roleController.text.trim(),
      level: _experienceLevel.isEmpty ? null : _experienceLevel,
      techStack: techStack.isEmpty ? null : techStack,
      questionCount: questionCount,
      durationMinutes: durationMinutes,
      visibility: _visibility,
      status: _status,
      instructions: _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim(),
      generateQuestions: true,
      companyId: companyId,
      collegeId: collegeId,
    );

    final failure = await ref
        .read(createInterviewViewModelProvider.notifier)
        .createInterview(params);

    if (!mounted) return;
    if (failure == null) {
      final interview =
          ref.read(createInterviewViewModelProvider).createdInterview;
      if (interview != null) widget.onCreated(interview);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createInterviewViewModelProvider);
    final recruiterState = ref.watch(recruiterViewModelProvider);
    final collegeState = ref.watch(collegeDashboardViewModelProvider);

    final recruiterWorkspaces = recruiterState.workspaces ?? [];
    final collegeWorkspaces = collegeState.workspaces ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSectionCard(
              icon: LucideIcons.clipboardList,
              title: 'Interview Basics',
              subtitle: 'Core details for your mock interview',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labeledField(
                    label: 'Interview title',
                    child: MyTextFormField(
                      controller: _titleController,
                      text: 'e.g. Frontend Engineering Mock Interview',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Interview title is required'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _labeledField(
                    label: 'Role focus',
                    child: MyTextFormField(
                      controller: _roleController,
                      text: 'e.g. Frontend Engineer, Data Scientist',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Role is required'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _dropdown(
                    label: 'Experience level',
                    value: _experienceLevel,
                    items: const [
                      ('', 'Not specified'),
                      ('Junior', 'Junior'),
                      ('Mid', 'Mid'),
                      ('Senior', 'Senior'),
                    ],
                    onChanged: (v) => setState(() => _experienceLevel = v),
                  ),
                  const SizedBox(height: 20),
                  _dropdown(
                    label: 'Interview type',
                    value: _interviewType,
                    items: const [
                      ('technical', 'Technical'),
                      ('behavioral', 'Behavioral'),
                      ('system_design', 'System Design'),
                      ('custom', 'Custom'),
                      ('mixed', 'Mixed'),
                    ],
                    onChanged: (v) => setState(() => _interviewType = v),
                  ),
                  const SizedBox(height: 20),
                  _labeledField(
                    label: 'Tech stack (comma separated)',
                    child: MyTextFormField(
                      controller: _techStackController,
                      text: 'e.g. React, TypeScript, Node.js',
                      optional: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _labeledField(
                    label: 'Number of questions',
                    child: _numberInput(
                      controller: _questionCountController,
                      hint: 'e.g. 8',
                      min: 1,
                      max: 30,
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final n = int.tryParse(v);
                        if (n == null || n < 1 || n > 30) {
                          return 'Enter a number between 1 and 30';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _labeledField(
                    label: 'Duration (minutes)',
                    child: _numberInput(
                      controller: _durationController,
                      hint: 'e.g. 25',
                      min: 5,
                      max: 120,
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final n = int.tryParse(v);
                        if (n == null || n < 5 || n > 120) {
                          return 'Enter a number between 5 and 120';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isRecruiter && recruiterWorkspaces.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSectionCard(
                icon: LucideIcons.building2,
                title: 'Workspace & Visibility',
                subtitle: 'Choose where this interview will appear',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dropdown(
                      label: 'Company Workspace',
                      value:
                          _selectedCompanyId ??
                          recruiterWorkspaces.first.companyId,
                      items: recruiterWorkspaces
                          .map((w) => (w.companyId, w.companyName))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCompanyId = v),
                    ),
                    const SizedBox(height: 16),
                    _dropdown(
                      label: 'Visibility',
                      value: _visibility,
                      items: const [
                        ('public', 'Public'),
                        ('private', 'Private'),
                      ],
                      onChanged: (v) => setState(() => _visibility = v),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.isCollege && collegeWorkspaces.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSectionCard(
                icon: LucideIcons.graduationCap,
                title: 'Workspace & Visibility',
                subtitle: 'Choose where this interview will appear',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dropdown(
                      label: 'College Workspace',
                      value:
                          _selectedCollegeId ??
                          collegeWorkspaces.first.collegeId,
                      items: collegeWorkspaces
                          .map((w) => (w.collegeId, w.collegeName))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCollegeId = v),
                    ),
                    const SizedBox(height: 16),
                    _dropdown(
                      label: 'Visibility',
                      value: _visibility,
                      items: const [
                        ('public', 'Public'),
                        ('private', 'Private'),
                        ('college_only', 'College Only'),
                      ],
                      onChanged: (v) => setState(() => _visibility = v),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            _buildSectionCard(
              icon: LucideIcons.fileText,
              title: 'Status',
              subtitle: 'Save as draft or publish immediately',
              child: _dropdown(
                label: 'Interview status',
                value: _status,
                items: const [
                  ('draft', 'Draft'),
                  ('published', 'Published'),
                ],
                onChanged: (v) => setState(() => _status = v),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              icon: LucideIcons.sparkles,
              title: 'Interview Guidance',
              subtitle: 'Help AI generate better questions',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Describe what this interview should focus on.',
                      hintStyle: const TextStyle(color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.bgTertiary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderStroke,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Instructions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Optional guidance for question generation and interview style.',
                      hintStyle: const TextStyle(color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.bgTertiary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderStroke,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.circleAlert, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            MyButton(
              onPressed: state.isLoading ? () {} : _submit,
              text: state.isLoading ? 'Creating...' : 'Create Interview',
              isLoading: state.isLoading,
              icon: state.isLoading ? null : Icon(LucideIcons.plus, size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Mock Interview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Configure your interview and let AI generate tailored questions.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textLight,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _numberInput({
    required TextEditingController controller,
    required String hint,
    required int min,
    required int max,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator,
      decoration: _inputDecoration(hint: hint),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textLight),
      filled: true,
      fillColor: AppColors.bgTertiary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderStroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<(String, String)> items,
    required void Function(String) onChanged,
  }) {
    final effectiveValue =
        items.any((e) => e.$1 == value) ? value : items.first.$1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: effectiveValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgTertiary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderStroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 20,
            color: AppColors.textMedium,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e.$1,
                  child: Text(
                    e.$2,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ],
    );
  }
}
