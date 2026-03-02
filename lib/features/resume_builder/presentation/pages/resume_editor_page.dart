import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/presentation/state/resume_builder_state.dart';
import 'package:kaarya/features/resume_builder/presentation/view_model/resume_builder_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── Helper data classes for form entries ────────────────────────────────────

class _ExpEntry {
  final companyCtrl = TextEditingController();
  final jobTitleCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool isCurrent = false;
  List<String> bullets = [];

  void fillFrom(ResumeExperienceEntity e) {
    companyCtrl.text = e.company;
    jobTitleCtrl.text = e.jobTitle;
    startDateCtrl.text = e.startDate;
    endDateCtrl.text = e.endDate;
    isCurrent = e.isCurrent;
    descCtrl.text = e.description ?? '';
    bullets = List.from(e.bullets);
  }

  Map<String, dynamic> toMap() => {
    'company': companyCtrl.text.trim(),
    'jobTitle': jobTitleCtrl.text.trim(),
    'startDate': startDateCtrl.text.trim(),
    'endDate': isCurrent ? '' : endDateCtrl.text.trim(),
    'isCurrent': isCurrent,
    'description': descCtrl.text.trim(),
    'bullets': bullets,
  };

  void dispose() {
    companyCtrl.dispose();
    jobTitleCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    descCtrl.dispose();
  }
}

class _EduEntry {
  final institutionCtrl = TextEditingController();
  final degreeCtrl = TextEditingController();
  final fieldCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final gpaCtrl = TextEditingController();

  void fillFrom(ResumeEducationEntity e) {
    institutionCtrl.text = e.institution;
    degreeCtrl.text = e.degree;
    fieldCtrl.text = e.fieldOfStudy;
    startDateCtrl.text = e.startDate;
    endDateCtrl.text = e.endDate;
    gpaCtrl.text = e.gpa ?? '';
  }

  Map<String, dynamic> toMap() => {
    'institution': institutionCtrl.text.trim(),
    'degree': degreeCtrl.text.trim(),
    'fieldOfStudy': fieldCtrl.text.trim(),
    'startDate': startDateCtrl.text.trim(),
    'endDate': endDateCtrl.text.trim(),
    'gpa': gpaCtrl.text.trim(),
  };

  void dispose() {
    institutionCtrl.dispose();
    degreeCtrl.dispose();
    fieldCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    gpaCtrl.dispose();
  }
}

class _ProjectEntry {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final urlCtrl = TextEditingController();
  List<String> technologies = [];

  void fillFrom(ResumeProjectEntity p) {
    nameCtrl.text = p.name;
    descCtrl.text = p.description ?? '';
    urlCtrl.text = p.url ?? '';
    technologies = List.from(p.technologies);
  }

  Map<String, dynamic> toMap() => {
    'name': nameCtrl.text.trim(),
    'description': descCtrl.text.trim(),
    'url': urlCtrl.text.trim(),
    'technologies': technologies,
  };

  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    urlCtrl.dispose();
  }
}

// ─── Step metadata ────────────────────────────────────────────────────────────

const _stepLabels = [
  'Setup',
  'Contact',
  'Summary',
  'Experience',
  'Education',
  'Projects',
  'Finalize',
];

const _templateOptions = [
  ('professional', 'Professional', 'Clean & Corporate', Color(0xFF0471B6)),
  ('modern', 'Modern', 'Bold & Creative', Color(0xFF7C3AED)),
  ('minimal', 'Minimal', 'Simple & Elegant', Color(0xFF374151)),
  ('executive', 'Executive', 'Leadership Style', Color(0xFF0F172A)),
];

// ─── Main page ────────────────────────────────────────────────────────────────

class ResumeEditorPage extends ConsumerStatefulWidget {
  final String? draftId;

  const ResumeEditorPage({super.key, this.draftId});

  @override
  ConsumerState<ResumeEditorPage> createState() => _ResumeEditorPageState();
}

class _ResumeEditorPageState extends ConsumerState<ResumeEditorPage> {
  int _step = 0;
  String? _draftId;
  bool _isLoading = false;

  // Accumulated content in the web schema — always sent as a whole to avoid
  // the backend replacing the entire content object on each step save.
  final Map<String, dynamic> _contentData = {};

  // Step 0 – Setup
  final _titleCtrl = TextEditingController();
  String _template = 'professional';

  // Step 1 – Contact
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();

  // Step 2 – Summary
  final _summaryCtrl = TextEditingController();
  final _targetRoleCtrl = TextEditingController();
  bool _isGeneratingSummary = false;

  // Step 3 – Experience
  final List<_ExpEntry> _experiences = [_ExpEntry()];
  int? _generatingBulletsFor;

  // Step 4 – Education & Skills
  final List<_EduEntry> _educations = [_EduEntry()];
  final List<String> _skills = [];
  final _skillInputCtrl = TextEditingController();

  // Step 5 – Projects
  final List<_ProjectEntry> _projects = [];
  final List<TextEditingController> _techInputCtrls = [];

  @override
  void initState() {
    super.initState();
    _draftId = widget.draftId;
    if (_draftId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraft());
    }
  }

  Future<void> _loadDraft() async {
    setState(() => _isLoading = true);
    await ref
        .read(resumeBuilderViewModelProvider.notifier)
        .loadDraftDetail(_draftId!);
    if (!mounted) return;
    final draft = ref.read(resumeBuilderViewModelProvider).draftDetailData;
    if (draft != null) _prefill(draft);
    setState(() => _isLoading = false);
  }

  void _prefill(ResumeDraftEntity d) {
    _titleCtrl.text = d.title;
    _template = d.template;
    _nameCtrl.text = d.personalInfo.name;
    _emailCtrl.text = d.personalInfo.email;
    _phoneCtrl.text = d.personalInfo.phone;
    _locationCtrl.text = d.personalInfo.location;
    _linkedinCtrl.text = d.personalInfo.linkedinUrl ?? '';
    _githubCtrl.text = d.personalInfo.githubUrl ?? '';
    _portfolioCtrl.text = d.personalInfo.portfolioUrl ?? '';
    _summaryCtrl.text = d.professionalSummary;

    _experiences.clear();
    if (d.experience.isEmpty) {
      _experiences.add(_ExpEntry());
    } else {
      for (final e in d.experience) {
        final entry = _ExpEntry()..fillFrom(e);
        _experiences.add(entry);
      }
    }

    _educations.clear();
    if (d.education.isEmpty) {
      _educations.add(_EduEntry());
    } else {
      for (final e in d.education) {
        final entry = _EduEntry()..fillFrom(e);
        _educations.add(entry);
      }
    }

    _skills.clear();
    _skills.addAll(d.skills.map((s) => s.name));

    _projects.clear();
    _techInputCtrls.clear();
    for (final p in d.projects) {
      final entry = _ProjectEntry()..fillFrom(p);
      _projects.add(entry);
      _techInputCtrls.add(TextEditingController());
    }

    // Populate the accumulated content cache so that each step update
    // carries all previously saved data (backend replaces content entirely).
    final nameParts = d.personalInfo.name.trim().split(' ');
    final locationParts = d.personalInfo.location.split(',');
    _contentData['personalInfo'] = {
      'firstName': nameParts.isNotEmpty ? nameParts.first : '',
      'lastName': nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
      'email': d.personalInfo.email,
      'phone': d.personalInfo.phone,
      'city': locationParts.isNotEmpty
          ? locationParts.first.trim()
          : d.personalInfo.location,
      'country': locationParts.length > 1 ? locationParts.last.trim() : '',
      'linkedin': d.personalInfo.linkedinUrl ?? '',
      'github': d.personalInfo.githubUrl ?? '',
      'portfolio': d.personalInfo.portfolioUrl ?? '',
    };
    _contentData['professionalSummary'] = d.professionalSummary;
    if (_targetRoleCtrl.text.isEmpty == false) {
      _contentData['targetRole'] = _targetRoleCtrl.text.trim();
    }
    _contentData['experience'] = d.experience
        .map(
          (e) => {
            'company': e.company,
            'position': e.jobTitle,
            'startDate': e.startDate,
            'endDate': e.isCurrent ? '' : e.endDate,
            'currentlyWorking': e.isCurrent,
            'bulletPoints': e.bullets,
          },
        )
        .toList();
    _contentData['education'] = d.education
        .map(
          (e) => {
            'school': e.institution,
            'degree': e.degree,
            'major': e.fieldOfStudy,
            'startDate': e.startDate,
            'endDate': e.endDate,
            'coursework': e.description ?? '',
          },
        )
        .toList();
    _contentData['skills'] = d.skills.map((s) => s.name).toList();
    _contentData['projects'] = d.projects
        .map(
          (p) => {
            'name': p.name,
            'description': p.description ?? '',
            'url': p.url ?? '',
            'technologies': p.technologies.join(', '),
          },
        )
        .toList();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _linkedinCtrl.dispose();
    _githubCtrl.dispose();
    _portfolioCtrl.dispose();
    _summaryCtrl.dispose();
    _targetRoleCtrl.dispose();
    _skillInputCtrl.dispose();
    for (final e in _experiences) {
      e.dispose();
    }
    for (final e in _educations) {
      e.dispose();
    }
    for (final p in _projects) {
      p.dispose();
    }
    for (final c in _techInputCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  Future<void> _nextStep() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final vm = ref.read(resumeBuilderViewModelProvider.notifier);

    if (_draftId == null) {
      // Step 0 → create draft
      final failure = await vm.createDraft(
        title: _titleCtrl.text.trim(),
        template: _template,
      );
      if (!mounted) return;
      if (failure != null) {
        _showError(failure.message);
        setState(() => _isLoading = false);
        return;
      }
      _draftId = ref.read(resumeBuilderViewModelProvider).draftDetailData?.id;
    } else {
      // Save current step data
      final fields = _currentFields();
      if (fields.isNotEmpty) {
        final failure = await vm.updateDraft(
          draftId: _draftId!,
          fields: fields,
        );
        if (!mounted) return;
        if (failure != null) {
          _showError(failure.message);
          setState(() => _isLoading = false);
          return;
        }
      }
    }

    setState(() {
      _isLoading = false;
      _step++;
    });
  }

  void _prevStep() => setState(() => _step--);

  bool _validate() {
    if (_step == 0 && _titleCtrl.text.trim().isEmpty) {
      _showError('Please enter a resume title');
      return false;
    }
    return true;
  }

  // Returns the fields to PATCH for the current step.
  // The backend replaces `content` entirely on each PATCH, so we always send
  // the full accumulated _contentData — not just the current step's portion.
  Map<String, dynamic> _currentFields() {
    switch (_step) {
      case 0:
        // Step 0 in edit mode: update title + template only (no content).
        return {'title': _titleCtrl.text.trim(), 'templateId': _template};
      case 1:
        final nameParts = _nameCtrl.text.trim().split(' ');
        _contentData['personalInfo'] = {
          'firstName': nameParts.isNotEmpty ? nameParts.first : '',
          'lastName': nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
          'email': _emailCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'city': _locationCtrl.text.trim(),
          'linkedin': _linkedinCtrl.text.trim(),
          'github': _githubCtrl.text.trim(),
          'portfolio': _portfolioCtrl.text.trim(),
        };
        return {
          'title': _titleCtrl.text.trim(),
          'templateId': _template,
          'content': Map<String, dynamic>.from(_contentData),
        };
      case 2:
        _contentData['professionalSummary'] = _summaryCtrl.text.trim();
        _contentData['targetRole'] = _targetRoleCtrl.text.trim();
        return {
          'targetRole': _targetRoleCtrl.text.trim(),
          'content': Map<String, dynamic>.from(_contentData),
        };
      case 3:
        _contentData['experience'] = _experiences
            .map(
              (e) => {
                'company': e.companyCtrl.text.trim(),
                'position': e.jobTitleCtrl.text.trim(),
                'startDate': e.startDateCtrl.text.trim(),
                'endDate': e.isCurrent ? '' : e.endDateCtrl.text.trim(),
                'currentlyWorking': e.isCurrent,
                'bulletPoints': e.bullets,
              },
            )
            .toList();
        return {'content': Map<String, dynamic>.from(_contentData)};
      case 4:
        _contentData['education'] = _educations
            .map(
              (e) => {
                'school': e.institutionCtrl.text.trim(),
                'degree': e.degreeCtrl.text.trim(),
                'major': e.fieldCtrl.text.trim(),
                'startDate': e.startDateCtrl.text.trim(),
                'endDate': e.endDateCtrl.text.trim(),
                'coursework': e.gpaCtrl.text.trim(),
              },
            )
            .toList();
        _contentData['skills'] = List<String>.from(_skills);
        return {'content': Map<String, dynamic>.from(_contentData)};
      case 5:
        _contentData['projects'] = _projects
            .map(
              (p) => {
                'name': p.nameCtrl.text.trim(),
                'description': p.descCtrl.text.trim(),
                'url': p.urlCtrl.text.trim(),
                'technologies': p.technologies.join(', '),
              },
            )
            .toList();
        return {'content': Map<String, dynamic>.from(_contentData)};
      default:
        return {};
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  // ─── AI helpers ─────────────────────────────────────────────────────────────

  Future<void> _generateSummary() async {
    if (_targetRoleCtrl.text.trim().isEmpty) {
      _showError('Enter a target role first');
      return;
    }
    setState(() => _isGeneratingSummary = true);
    final (result, failure) = await ref
        .read(resumeBuilderViewModelProvider.notifier)
        .generateAiSummary(
          skills: _skills,
          experience: _experiences
              .map((e) => '${e.jobTitleCtrl.text} at ${e.companyCtrl.text}')
              .where((s) => s.trim() != 'at')
              .toList(),
          targetRole: _targetRoleCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isGeneratingSummary = false);
    if (failure != null) {
      _showError(failure.message);
    } else if (result != null) {
      _summaryCtrl.text = result.summary;
    }
  }

  Future<void> _generateBullets(int index) async {
    final entry = _experiences[index];
    if (entry.jobTitleCtrl.text.trim().isEmpty) {
      _showError('Enter a job title first');
      return;
    }
    setState(() => _generatingBulletsFor = index);
    final (result, failure) = await ref
        .read(resumeBuilderViewModelProvider.notifier)
        .generateExperienceBullets(
          jobTitle: entry.jobTitleCtrl.text.trim(),
          responsibilities: entry.descCtrl.text.trim(),
          techStack: _skills,
        );
    if (!mounted) return;
    setState(() {
      _generatingBulletsFor = null;
      if (result != null) {
        entry.bullets = result.bullets;
      }
    });
    if (failure != null) _showError(failure.message);
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.draftId != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Resume' : 'Create Resume',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.pop(context, true),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appSubtleBorderColor(context)),
        ),
      ),
      body: _isLoading && widget.draftId != null && _step == 0
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStepContent(),
                    ),
                  ),
                ),
                _buildNavBar(),
              ],
            ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: appSurfaceColor(context),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (int i = 0; i < _stepLabels.length; i++) ...[
                _stepDot(i),
                if (i < _stepLabels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < _step
                          ? AppColors.primary
                          : appBorderColor(context),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_step + 1} of ${_stepLabels.length} — ${_stepLabels[_step]}',
            style: TextStyle(
              fontSize: 12,
              color: appTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(int i) {
    final isDone = i < _step;
    final isCurrent = i == _step;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isDone || isCurrent
            ? AppColors.primary
            : appMutedSurfaceColor(context),
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Center(
        child: isDone
            ? const Icon(LucideIcons.check, size: 13, color: Colors.white)
            : Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isCurrent
                      ? Colors.white
                      : appTextSecondaryColor(context),
                ),
              ),
      ),
    );
  }

  Widget _buildNavBar() {
    final isLastStep = _step == _stepLabels.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: appSurfaceColor(context),
        border: Border(top: BorderSide(color: appSubtleBorderColor(context))),
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _prevStep,
                icon: const Icon(LucideIcons.chevronLeft, size: 16),
                label: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: _step > 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: isLastStep
                  ? () => Navigator.pop(context, true)
                  : _isLoading
                  ? null
                  : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep
                    ? const Color(0xFF059669)
                    : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? 'Done' : 'Save & Continue',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (!isLastStep) ...[
                          const SizedBox(width: 6),
                          const Icon(LucideIcons.chevronRight, size: 16),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: switch (_step) {
        0 => _buildSetup(),
        1 => _buildContact(),
        2 => _buildSummary(),
        3 => _buildExperience(),
        4 => _buildEducation(),
        5 => _buildProjects(),
        _ => _buildFinalize(),
      },
    );
  }

  // ─── Step 0: Setup ──────────────────────────────────────────────────────────

  Widget _buildSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          LucideIcons.fileText,
          'Resume Setup',
          'Start with a title and template',
        ),
        const SizedBox(height: 20),
        _label('Resume Title *'),
        const SizedBox(height: 6),
        _field(_titleCtrl, 'e.g. Software Engineer Resume 2025'),
        const SizedBox(height: 24),
        _label('Choose Template'),
        const SizedBox(height: 12),
        ...(_templateOptions.map((opt) {
          final (value, name, desc, color) = opt;
          final isSelected = _template == value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _template = value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withAlpha(isDarkMode(context) ? 22 : 12)
                      : appSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : appBorderColor(context),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.layoutTemplate,
                        size: 20,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? color
                                  : appTextPrimaryColor(context),
                            ),
                          ),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 12,
                              color: appTextSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        })),
      ],
    );
  }

  // ─── Step 1: Contact ────────────────────────────────────────────────────────

  Widget _buildContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          LucideIcons.user,
          'Contact Information',
          'How employers can reach you',
        ),
        const SizedBox(height: 20),
        _label('Full Name *'),
        const SizedBox(height: 6),
        _field(_nameCtrl, 'e.g. John Doe'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Email *'),
                  const SizedBox(height: 6),
                  _field(
                    _emailCtrl,
                    'john@email.com',
                    type: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Phone'),
                  const SizedBox(height: 6),
                  _field(
                    _phoneCtrl,
                    '+1 234 567 8900',
                    type: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _label('Location'),
        const SizedBox(height: 6),
        _field(_locationCtrl, 'City, Country'),
        const SizedBox(height: 20),
        _subHeader('Online Profiles (Optional)'),
        const SizedBox(height: 12),
        _iconField(LucideIcons.linkedin, _linkedinCtrl, 'LinkedIn URL'),
        const SizedBox(height: 10),
        _iconField(LucideIcons.github, _githubCtrl, 'GitHub URL'),
        const SizedBox(height: 10),
        _iconField(LucideIcons.globe, _portfolioCtrl, 'Portfolio URL'),
      ],
    );
  }

  // ─── Step 2: Summary ────────────────────────────────────────────────────────

  Widget _buildSummary() {
    final state = ref.watch(resumeBuilderViewModelProvider);
    final isGenerating =
        state.aiSummaryStatus == ResumeBuilderLoadStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          LucideIcons.pencilLine,
          'Professional Summary',
          'A brief overview of your career',
        ),
        const SizedBox(height: 20),
        _label('Target Role'),
        const SizedBox(height: 6),
        _field(_targetRoleCtrl, 'e.g. Senior Software Engineer'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label('Professional Summary'),
            TextButton.icon(
              onPressed: (isGenerating || _isGeneratingSummary)
                  ? null
                  : _generateSummary,
              icon: (isGenerating || _isGeneratingSummary)
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(LucideIcons.sparkles, size: 14),
              label: const Text(
                'Generate with AI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _field(
          _summaryCtrl,
          'Describe your professional background, key strengths, and career goals...',
          maxLines: 6,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.info, size: 14, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fill in your target role first, then tap "Generate with AI" for a personalized summary.',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Step 3: Experience ─────────────────────────────────────────────────────

  Widget _buildExperience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          LucideIcons.briefcase,
          'Work Experience',
          'Your professional history',
        ),
        const SizedBox(height: 16),
        ..._experiences.asMap().entries.map(
          (entry) => _expCard(entry.key, entry.value),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _experiences.add(_ExpEntry())),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text(
              'Add Experience',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _expCard(int index, _ExpEntry entry) {
    final isGenerating = _generatingBulletsFor == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Work Experience',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                if (_experiences.length > 1)
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: AppColors.error,
                    ),
                    onPressed: () => setState(() {
                      entry.dispose();
                      _experiences.removeAt(index);
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Company'),
                          const SizedBox(height: 4),
                          _field(entry.companyCtrl, 'Company name'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Job Title'),
                          const SizedBox(height: 4),
                          _field(entry.jobTitleCtrl, 'Role title'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Start Date'),
                          const SizedBox(height: 4),
                          _field(entry.startDateCtrl, 'Jan 2022'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('End Date'),
                          const SizedBox(height: 4),
                          _field(
                            entry.endDateCtrl,
                            'Present',
                            enabled: !entry.isCurrent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (_, setLocal) => GestureDetector(
                    onTap: () {
                      setLocal(() => entry.isCurrent = !entry.isCurrent);
                      setState(() {});
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: entry.isCurrent
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: entry.isCurrent
                                  ? AppColors.primary
                                  : AppColors.borderStroke,
                            ),
                          ),
                          child: entry.isCurrent
                              ? const Icon(
                                  LucideIcons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Currently working here',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _label('Description'),
                const SizedBox(height: 4),
                _field(
                  entry.descCtrl,
                  'Describe your role and responsibilities...',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                // Bullets section
                if (entry.bullets.isNotEmpty) ...[
                  _label('Key Achievements'),
                  const SizedBox(height: 6),
                  ...entry.bullets.asMap().entries.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b.value,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => entry.bullets.removeAt(b.key)),
                            child: const Icon(
                              LucideIcons.x,
                              size: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isGenerating
                        ? null
                        : () => _generateBullets(index),
                    icon: isGenerating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(LucideIcons.sparkles, size: 14),
                    label: Text(
                      isGenerating ? 'Generating...' : 'Generate AI Bullets',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 4: Education & Skills ─────────────────────────────────────────────

  Widget _buildEducation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          LucideIcons.graduationCap,
          'Education & Skills',
          'Your academic background and skill set',
        ),
        const SizedBox(height: 16),
        ..._educations.asMap().entries.map((e) => _eduCard(e.key, e.value)),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _educations.add(_EduEntry())),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text(
              'Add Education',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _subHeader('Skills'),
        const SizedBox(height: 12),
        if (_skills.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills
                .asMap()
                .entries
                .map((e) => _skillChip(e.key, e.value))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: _field(
                _skillInputCtrl,
                'Add a skill (e.g. Flutter, Python...)',
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _addSkill,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _eduCard(int index, _EduEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.graduationCap,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Education',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                if (_educations.length > 1)
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: AppColors.error,
                    ),
                    onPressed: () => setState(() {
                      entry.dispose();
                      _educations.removeAt(index);
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Institution'),
                const SizedBox(height: 4),
                _field(entry.institutionCtrl, 'University / College name'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Degree'),
                          const SizedBox(height: 4),
                          _field(entry.degreeCtrl, "Bachelor's"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Field of Study'),
                          const SizedBox(height: 4),
                          _field(entry.fieldCtrl, 'Computer Science'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Start Date'),
                          const SizedBox(height: 4),
                          _field(entry.startDateCtrl, 'Sep 2019'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('End Date'),
                          const SizedBox(height: 4),
                          _field(entry.endDateCtrl, 'Jun 2023'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('GPA (opt.)'),
                          const SizedBox(height: 4),
                          _field(entry.gpaCtrl, '3.8'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillChip(int index, String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _skills.removeAt(index)),
            child: const Icon(
              LucideIcons.x,
              size: 13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _addSkill() {
    final skill = _skillInputCtrl.text.trim();
    if (skill.isEmpty || _skills.contains(skill)) return;
    setState(() {
      _skills.add(skill);
      _skillInputCtrl.clear();
    });
  }

  // ─── Step 5: Projects ───────────────────────────────────────────────────────

  Widget _buildProjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          LucideIcons.folderOpen,
          'Projects',
          'Showcase your work (optional)',
        ),
        const SizedBox(height: 16),
        if (_projects.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Column(
              children: [
                Icon(
                  LucideIcons.folderOpen,
                  size: 32,
                  color: AppColors.textLight,
                ),
                SizedBox(height: 10),
                Text(
                  'No projects added yet',
                  style: TextStyle(fontSize: 14, color: AppColors.textLight),
                ),
                SizedBox(height: 4),
                Text(
                  'Add personal, academic, or open-source projects',
                  style: TextStyle(fontSize: 12, color: AppColors.textMedium),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._projects.asMap().entries.map((e) => _projectCard(e.key, e.value)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _projects.add(_ProjectEntry());
                _techInputCtrls.add(TextEditingController());
              });
            },
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text(
              'Add Project',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _projectCard(int index, _ProjectEntry entry) {
    final techCtrl = _techInputCtrls[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.folderOpen,
                  size: 16,
                  color: Color(0xFF7C3AED),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Project',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.trash2,
                    size: 16,
                    color: AppColors.error,
                  ),
                  onPressed: () => setState(() {
                    entry.dispose();
                    _projects.removeAt(index);
                    techCtrl.dispose();
                    _techInputCtrls.removeAt(index);
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Project Name'),
                const SizedBox(height: 4),
                _field(entry.nameCtrl, 'e.g. Portfolio Website'),
                const SizedBox(height: 10),
                _label('Description'),
                const SizedBox(height: 4),
                _field(
                  entry.descCtrl,
                  'What does this project do?',
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                _label('Project URL (optional)'),
                const SizedBox(height: 4),
                _field(entry.urlCtrl, 'https://github.com/...'),
                const SizedBox(height: 10),
                _label('Technologies'),
                const SizedBox(height: 6),
                if (entry.technologies.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entry.technologies.asMap().entries.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF7C3AED).withAlpha(60),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.value,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => setState(
                                () => entry.technologies.removeAt(t.key),
                              ),
                              child: const Icon(
                                LucideIcons.x,
                                size: 12,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _field(techCtrl, 'Add technology (e.g. Flutter)'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final tech = techCtrl.text.trim();
                        if (tech.isEmpty || entry.technologies.contains(tech)) {
                          return;
                        }
                        setState(() {
                          entry.technologies.add(tech);
                          techCtrl.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 6: Finalize ───────────────────────────────────────────────────────

  Widget _buildFinalize() {
    final state = ref.watch(resumeBuilderViewModelProvider);
    final vm = ref.read(resumeBuilderViewModelProvider.notifier);
    final isGeneratingPdf =
        state.generatePdfStatus == ResumeBuilderLoadStatus.loading;
    final isSaving = state.saveResumeStatus == ResumeBuilderLoadStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          LucideIcons.circleCheck,
          'Finalize Resume',
          'Review and export your resume',
        ),
        const SizedBox(height: 16),
        // Summary cards
        _finalizeSummaryCard(
          LucideIcons.user,
          'Contact',
          _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Not filled',
          AppColors.primary,
        ),
        _finalizeSummaryCard(
          LucideIcons.pencilLine,
          'Summary',
          _summaryCtrl.text.isNotEmpty
              ? '${_summaryCtrl.text.length} chars'
              : 'Not filled',
          const Color(0xFF7C3AED),
        ),
        _finalizeSummaryCard(
          LucideIcons.briefcase,
          'Experience',
          '${_experiences.where((e) => e.companyCtrl.text.isNotEmpty).length} position(s) added',
          const Color(0xFF059669),
        ),
        _finalizeSummaryCard(
          LucideIcons.graduationCap,
          'Education',
          '${_educations.where((e) => e.institutionCtrl.text.isNotEmpty).length} school(s) added',
          const Color(0xFFD97706),
        ),
        _finalizeSummaryCard(
          LucideIcons.code,
          'Skills',
          _skills.isNotEmpty
              ? '${_skills.length} skill(s): ${_skills.take(3).join(', ')}...'
              : 'None added',
          const Color(0xFFEF4444),
        ),
        if (_projects.isNotEmpty)
          _finalizeSummaryCard(
            LucideIcons.folderOpen,
            'Projects',
            '${_projects.length} project(s) added',
            const Color(0xFF0891B2),
          ),
        const SizedBox(height: 20),
        // Generate PDF
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_draftId == null || isGeneratingPdf)
                ? null
                : () => _handleGeneratePdf(vm),
            icon: isGeneratingPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(LucideIcons.fileDown, size: 18),
            label: Text(
              isGeneratingPdf ? 'Generating PDF...' : 'Generate PDF',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Save as active resume
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: (_draftId == null || isSaving)
                ? null
                : () => _handleSaveAsResume(vm),
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Color(0xFF059669),
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(LucideIcons.save, size: 18),
            label: Text(
              isSaving ? 'Saving...' : 'Save as Active Resume',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF059669),
              side: const BorderSide(color: Color(0xFF059669)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (state.generatePdfData != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.circleCheck,
                  size: 18,
                  color: const Color(0xFF059669),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PDF ready!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.generatePdfData!.pdfUrl,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: state.generatePdfData!.pdfUrl),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL copied!')),
                    );
                  },
                  child: const Text('Copy', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'Tap "Done" below to go back to your resume list.',
          style: TextStyle(fontSize: 13, color: AppColors.textMedium),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _finalizeSummaryCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGeneratePdf(ResumeBuilderViewModel vm) async {
    final (result, failure) = await vm.generatePdf(_draftId!);
    if (!mounted) return;
    if (failure != null) _showError(failure.message);
  }

  Future<void> _handleSaveAsResume(ResumeBuilderViewModel vm) async {
    final failure = await vm.saveAsResume(_draftId!);
    if (!mounted) return;
    if (failure != null) {
      _showError(failure.message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved as your active resume!'),
          backgroundColor: AppColors.success2,
        ),
      );
    }
  }

  // ─── Shared helpers ──────────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: appTextPrimaryColor(context),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: appTextPrimaryColor(context),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? appSurfaceColor(context)
            : appMutedSurfaceColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: type,
        enabled: enabled,
        style: TextStyle(fontSize: 14, color: appTextPrimaryColor(context)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: appTextSecondaryColor(context),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: maxLines > 1 ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _iconField(IconData icon, TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: appSurfaceColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, size: 18, color: appTextSecondaryColor(context)),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              style: TextStyle(
                fontSize: 14,
                color: appTextPrimaryColor(context),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: appTextSecondaryColor(context),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
