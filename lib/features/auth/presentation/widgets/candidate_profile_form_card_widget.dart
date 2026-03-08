// coverage:ignore-file
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';
import 'package:kaarya/features/applications/presentation/state/application_state.dart';
import 'package:kaarya/features/applications/presentation/view_model/application_view_model.dart';
import 'package:kaarya/features/auth/domain/entities/candidate_profile_entity.dart';
import 'package:kaarya/features/auth/domain/usecases/upload_certification_usecase.dart';
import 'package:kaarya/features/auth/presentation/widgets/update_profile_form_card_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

enum _ProfileSubTab {
  general,
  skills,
  experience,
  education,
  resume,
  certifications,
  salary,
}

class CandidateProfileFormCard extends ConsumerStatefulWidget {
  const CandidateProfileFormCard({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailAddressController,
    required this.profileImageUrl,
    this.initialProfile,
    this.onPhotoChanged,
    this.onSave,
    this.isSaving = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailAddressController;
  final String profileImageUrl;
  final CandidateProfileEntity? initialProfile;
  final ValueChanged<File?>? onPhotoChanged;
  final Future<void> Function(Map<String, dynamic>? candidateProfile)? onSave;
  final bool isSaving;

  @override
  ConsumerState<CandidateProfileFormCard> createState() =>
      _CandidateProfileFormCardState();
}

class _SkillEntry {
  const _SkillEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.proficiency,
  });

  final String id;
  final String name;
  final String category;
  final String proficiency;
}

class _ExperienceEntry {
  _ExperienceEntry({
    required this.id,
    required this.jobTitleController,
    required this.companyController,
    required this.locationController,
    required this.descriptionController,
    this.startDate,
    this.endDate,
    this.employmentType = 'Full-time',
    this.isCurrent = false,
  });

  final String id;
  final TextEditingController jobTitleController;
  final TextEditingController companyController;
  final TextEditingController locationController;
  final TextEditingController descriptionController;
  String? startDate;
  String? endDate;
  String employmentType;
  bool isCurrent;

  void dispose() {
    jobTitleController.dispose();
    companyController.dispose();
    locationController.dispose();
    descriptionController.dispose();
  }
}

class _EducationEntry {
  _EducationEntry({
    required this.id,
    required this.institutionController,
    required this.degreeController,
    required this.fieldOfStudyController,
    required this.gradeController,
    required this.highlightsController,
    this.startDate,
    this.endDate,
  });

  final String id;
  final TextEditingController institutionController;
  final TextEditingController degreeController;
  final TextEditingController fieldOfStudyController;
  final TextEditingController gradeController;
  final TextEditingController highlightsController;
  String? startDate;
  String? endDate;

  void dispose() {
    institutionController.dispose();
    degreeController.dispose();
    fieldOfStudyController.dispose();
    gradeController.dispose();
    highlightsController.dispose();
  }
}

class _CertificationEntry {
  _CertificationEntry({
    required this.id,
    required this.nameController,
    required this.issuerController,
    required this.credentialIdController,
    required this.credentialUrlController,
    this.issueDate,
    this.expiryDate,
    this.mediaUrl,
    this.mediaMimeType,
  });

  final String id;
  final TextEditingController nameController;
  final TextEditingController issuerController;
  final TextEditingController credentialIdController;
  final TextEditingController credentialUrlController;
  String? issueDate;
  String? expiryDate;
  String? mediaUrl;
  String? mediaMimeType;

  void dispose() {
    nameController.dispose();
    issuerController.dispose();
    credentialIdController.dispose();
    credentialUrlController.dispose();
  }
}

class _CandidateProfileFormCardState
    extends ConsumerState<CandidateProfileFormCard> {
  static const _uuid = Uuid();
  static const _tabMeta = [
    (_ProfileSubTab.general, 'General', LucideIcons.userRound),
    (_ProfileSubTab.skills, 'Skills', LucideIcons.code),
    (_ProfileSubTab.experience, 'Experience', LucideIcons.briefcaseBusiness),
    (_ProfileSubTab.education, 'Education', LucideIcons.graduationCap),
    (_ProfileSubTab.resume, 'Resume', LucideIcons.fileText),
    (_ProfileSubTab.certifications, 'Certifications', LucideIcons.badgeCheck),
    (_ProfileSubTab.salary, 'Salary', LucideIcons.dollarSign),
  ];

  _ProfileSubTab _selectedSubTab = _ProfileSubTab.skills;
  bool _didPrefillFromProfile = false;

  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _portfolioUrlController = TextEditingController();
  final TextEditingController _skillNameController = TextEditingController();
  final TextEditingController _preferredRoleController =
      TextEditingController();
  final TextEditingController _preferredLocationController =
      TextEditingController();
  final TextEditingController _portfolioLinkController =
      TextEditingController();
  final TextEditingController _salaryMinController = TextEditingController();
  final TextEditingController _salaryMaxController = TextEditingController();

  final List<_SkillEntry> _skillEntries = [];
  final List<String> _preferredRoles = [];
  final List<String> _preferredLocations = [];
  final List<String> _portfolioLinks = [];
  final List<_ExperienceEntry> _experienceEntries = [];
  final List<_EducationEntry> _educationEntries = [];
  final List<_CertificationEntry> _certificationEntries = [];
  final Set<String> _uploadingCertificationIds = <String>{};
  final Set<String> _preferredWorkModes = <String>{};

  String _skillCategory = 'Technical';
  String _skillProficiency = 'intermediate';
  String _salaryCurrency = 'NPR';
  String _salaryPeriod = 'yearly';
  bool _salaryNegotiable = false;
  String? _selectedDefaultResumeId;
  bool _openToWork = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(applicationViewModelProvider.notifier).loadMyResumes();
      if (widget.initialProfile != null) {
        _applyPrefill(widget.initialProfile);
      } else {
        _ensureEmptyEntries();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CandidateProfileFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_didPrefillFromProfile) return;
    if (widget.initialProfile != null &&
        widget.initialProfile != oldWidget.initialProfile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _applyPrefill(widget.initialProfile);
        }
      });
    }
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioUrlController.dispose();
    _skillNameController.dispose();
    _preferredRoleController.dispose();
    _preferredLocationController.dispose();
    _portfolioLinkController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    for (final entry in _experienceEntries) {
      entry.dispose();
    }
    for (final entry in _educationEntries) {
      entry.dispose();
    }
    for (final entry in _certificationEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _ensureEmptyEntries() {
    if (_experienceEntries.isEmpty) {
      _experienceEntries.add(_createExperienceEntry());
    }
    if (_educationEntries.isEmpty) {
      _educationEntries.add(_createEducationEntry());
    }
    if (_certificationEntries.isEmpty) {
      _certificationEntries.add(_createCertificationEntry());
    }
    setState(() {});
  }

  _ExperienceEntry _createExperienceEntry([CandidateExperienceEntity? data]) {
    return _ExperienceEntry(
      id: data?.id ?? _uuid.v4(),
      jobTitleController: TextEditingController(text: data?.title ?? ''),
      companyController: TextEditingController(text: data?.company ?? ''),
      locationController: TextEditingController(text: data?.location ?? ''),
      descriptionController: TextEditingController(
        text: data?.description ?? '',
      ),
      startDate: data?.startDate,
      endDate: data?.isCurrent == true ? null : data?.endDate,
      employmentType: data?.employmentType ?? 'Full-time',
      isCurrent: data?.isCurrent ?? false,
    );
  }

  _EducationEntry _createEducationEntry([CandidateEducationEntity? data]) {
    return _EducationEntry(
      id: data?.id ?? _uuid.v4(),
      institutionController: TextEditingController(
        text: data?.institution ?? '',
      ),
      degreeController: TextEditingController(text: data?.degree ?? ''),
      fieldOfStudyController: TextEditingController(
        text: data?.fieldOfStudy ?? '',
      ),
      gradeController: TextEditingController(text: data?.grade ?? ''),
      highlightsController: TextEditingController(
        text: data?.description ?? '',
      ),
      startDate: data?.startDate,
      endDate: data?.endDate,
    );
  }

  _CertificationEntry _createCertificationEntry([
    CandidateCertificationEntity? data,
  ]) {
    return _CertificationEntry(
      id: data?.id ?? _uuid.v4(),
      nameController: TextEditingController(text: data?.name ?? ''),
      issuerController: TextEditingController(
        text: data?.issuingOrganization ?? '',
      ),
      credentialIdController: TextEditingController(
        text: data?.credentialId ?? '',
      ),
      credentialUrlController: TextEditingController(
        text: data?.credentialUrl ?? '',
      ),
      issueDate: data?.issueDate,
      expiryDate: data?.noExpiry == true ? null : data?.expiryDate,
      mediaUrl: data?.mediaUrl,
      mediaMimeType: data?.mediaMimeType,
    );
  }

  void _applyPrefill(CandidateProfileEntity? profile) {
    if (profile == null || _didPrefillFromProfile) return;
    _didPrefillFromProfile = true;

    _headlineController.text = profile.headline ?? '';
    _phoneController.text = profile.phone ?? '';
    _locationController.text = profile.location ?? '';
    _summaryController.text = profile.summary ?? '';
    _linkedinController.text = profile.linkedinUrl ?? '';
    _githubController.text = profile.githubUrl ?? '';
    _portfolioUrlController.text = profile.portfolioUrl ?? '';
    _salaryMinController.text = _formatSalaryAmount(
      profile.salaryExpectation?.min,
    );
    _salaryMaxController.text = _formatSalaryAmount(
      profile.salaryExpectation?.max,
    );
    _salaryCurrency = profile.salaryExpectation?.currency ?? 'NPR';
    _salaryPeriod = profile.salaryExpectation?.period ?? 'yearly';
    _salaryNegotiable = profile.salaryExpectation?.isNegotiable ?? false;
    _selectedDefaultResumeId = profile.defaultResumeId;
    _openToWork = profile.openToWork;

    _skillEntries
      ..clear()
      ..addAll(
        profile.skills.map(
          (skill) => _SkillEntry(
            id: skill.id ?? _uuid.v4(),
            name: skill.name,
            category: skill.category,
            proficiency: _normalizeSkillProficiency(skill.proficiency),
          ),
        ),
      );
    _preferredRoles
      ..clear()
      ..addAll(profile.preferredRoles);
    _preferredLocations
      ..clear()
      ..addAll(profile.preferredLocations);
    _portfolioLinks
      ..clear()
      ..addAll(profile.portfolioLinks);
    _preferredWorkModes
      ..clear()
      ..addAll(
        profile.preferredWorkModes
            .map((mode) => mode.trim().toLowerCase())
            .where((mode) => mode.isNotEmpty),
      );

    for (final entry in _experienceEntries) {
      entry.dispose();
    }
    _experienceEntries
      ..clear()
      ..addAll(
        profile.experience.isNotEmpty
            ? profile.experience.map(_createExperienceEntry)
            : [_createExperienceEntry()],
      );

    for (final entry in _educationEntries) {
      entry.dispose();
    }
    _educationEntries
      ..clear()
      ..addAll(
        profile.education.isNotEmpty
            ? profile.education.map(_createEducationEntry)
            : [_createEducationEntry()],
      );

    for (final entry in _certificationEntries) {
      entry.dispose();
    }
    _certificationEntries
      ..clear()
      ..addAll(
        profile.certifications.isNotEmpty
            ? profile.certifications.map(_createCertificationEntry)
            : [_createCertificationEntry()],
      );

    setState(() {});
  }

  String _formatSalaryAmount(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  String _normalizeSkillProficiency(String value) {
    const allowed = {
      'beginner',
      'intermediate',
      'advanced',
      'expert',
      'master',
    };
    final normalized = value.trim().toLowerCase();
    if (allowed.contains(normalized)) return normalized;
    return 'intermediate';
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  void _addSkill() {
    final name = _skillNameController.text.trim();
    if (name.isEmpty) return;
    final exists = _skillEntries.any(
      (skill) => skill.name.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      SnackbarUtils.showWarning(context, 'That skill is already added.');
      return;
    }
    setState(() {
      _skillEntries.add(
        _SkillEntry(
          id: _uuid.v4(),
          name: name,
          category: _skillCategory,
          proficiency: _skillProficiency,
        ),
      );
      _skillNameController.clear();
    });
  }

  void _removeSkill(String id) {
    setState(() {
      _skillEntries.removeWhere((skill) => skill.id == id);
    });
  }

  void _addTag({
    required TextEditingController controller,
    required List<String> target,
    required int maxItems,
  }) {
    final raw = controller.text.replaceAll(',', ' ').trim();
    if (raw.isEmpty) return;
    if (target.length >= maxItems) {
      SnackbarUtils.showWarning(
        context,
        'You have reached the limit for this list.',
      );
      return;
    }
    final exists = target.any(
      (item) => item.toLowerCase() == raw.toLowerCase(),
    );
    if (exists) {
      controller.clear();
      return;
    }
    setState(() {
      target.add(raw);
      controller.clear();
    });
  }

  void _handleTagTyping({
    required String value,
    required TextEditingController controller,
    required List<String> target,
    required int maxItems,
  }) {
    if (value.endsWith(',')) {
      _addTag(controller: controller, target: target, maxItems: maxItems);
    }
  }

  void _removeTag(List<String> target, String value) {
    setState(() {
      target.remove(value);
    });
  }

  void _toggleWorkMode(String mode) {
    setState(() {
      if (_preferredWorkModes.contains(mode)) {
        _preferredWorkModes.remove(mode);
      } else {
        _preferredWorkModes.add(mode);
      }
    });
  }

  void _addExperience() {
    setState(() {
      _experienceEntries.add(_createExperienceEntry());
    });
  }

  void _removeExperience(int index) {
    if (_experienceEntries.length == 1) return;
    final entry = _experienceEntries.removeAt(index);
    entry.dispose();
    setState(() {});
  }

  void _addEducation() {
    setState(() {
      _educationEntries.add(_createEducationEntry());
    });
  }

  void _removeEducation(int index) {
    if (_educationEntries.length == 1) return;
    final entry = _educationEntries.removeAt(index);
    entry.dispose();
    setState(() {});
  }

  void _addCertification() {
    setState(() {
      _certificationEntries.add(_createCertificationEntry());
    });
  }

  void _removeCertification(int index) {
    if (_certificationEntries.length == 1) return;
    final entry = _certificationEntries.removeAt(index);
    entry.dispose();
    setState(() {});
  }

  Future<void> _pickCertificationFile(_CertificationEntry entry) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    final file = result?.files.single;
    final filePath = file?.path;
    if (filePath == null) return;

    setState(() {
      _uploadingCertificationIds.add(entry.id);
    });

    final upload = await ref.read(uploadCertificationUseCaseProvider)(
      UploadCertificationParams(filePath: filePath),
    );

    if (!mounted) return;

    upload.fold(
      (failure) => SnackbarUtils.showError(context, failure.message),
      (url) {
        setState(() {
          entry.mediaUrl = url;
          entry.mediaMimeType = _mimeTypeFromPath(filePath);
        });
        SnackbarUtils.showSuccess(context, 'Certification file uploaded.');
      },
    );

    setState(() {
      _uploadingCertificationIds.remove(entry.id);
    });
  }

  String? _mimeTypeFromPath(String filePath) {
    switch (p.extension(filePath).toLowerCase()) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return null;
    }
  }

  Future<void> _pickResumeFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
    );
    final filePath = result?.files.single.path;
    if (filePath == null) return;

    final (resume, failure) = await ref
        .read(applicationViewModelProvider.notifier)
        .uploadResume(filePath: filePath);

    if (!mounted) return;

    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }

    setState(() {
      _selectedDefaultResumeId ??= resume?.id;
    });
    SnackbarUtils.showSuccess(context, 'Resume uploaded successfully.');
  }

  Future<void> _previewResume(ResumeEntity resume) async {
    final uri = Uri.tryParse(resume.url);
    if (uri == null) {
      SnackbarUtils.showError(context, 'Invalid resume URL.');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      SnackbarUtils.showError(context, 'Could not open this resume.');
    }
  }

  Future<void> _downloadResume(ResumeEntity resume) async {
    try {
      final dir = await getTemporaryDirectory();
      final savePath = p.join(dir.path, resume.fileName);
      await Dio().download(resume.url, savePath);
      await OpenFilex.open(savePath);
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Could not download this resume.');
    }
  }

  Future<void> _deleteResume(String resumeId) async {
    final failure = await ref
        .read(applicationViewModelProvider.notifier)
        .deleteResume(resumeId: resumeId);

    if (!mounted) return;

    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }

    setState(() {
      if (_selectedDefaultResumeId == resumeId) {
        _selectedDefaultResumeId = null;
      }
    });
    SnackbarUtils.showSuccess(context, 'Resume removed.');
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _parseAmount(String value) {
    final cleaned = value.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  Map<String, dynamic> _experienceToPayload(_ExperienceEntry entry) {
    final data = <String, dynamic>{
      'id': entry.id,
      'jobTitle': entry.jobTitleController.text.trim(),
      'companyName': entry.companyController.text.trim(),
      'employmentType': entry.employmentType,
      'currentlyWorking': entry.isCurrent,
    };
    final location = _trimOrNull(entry.locationController.text);
    final description = _trimOrNull(entry.descriptionController.text);
    if (location != null) data['location'] = location;
    if (entry.startDate != null && entry.startDate!.isNotEmpty) {
      data['startDate'] = entry.startDate;
    }
    if (!entry.isCurrent &&
        entry.endDate != null &&
        entry.endDate!.isNotEmpty) {
      data['endDate'] = entry.endDate;
    }
    if (description != null) data['description'] = description;
    return data;
  }

  Map<String, dynamic> _educationToPayload(_EducationEntry entry) {
    final data = <String, dynamic>{
      'id': entry.id,
      'institution': entry.institutionController.text.trim(),
      'degree': entry.degreeController.text.trim(),
    };
    final fieldOfStudy = _trimOrNull(entry.fieldOfStudyController.text);
    final grade = _trimOrNull(entry.gradeController.text);
    final description = _trimOrNull(entry.highlightsController.text);
    if (fieldOfStudy != null) data['fieldOfStudy'] = fieldOfStudy;
    if (entry.startDate != null && entry.startDate!.isNotEmpty) {
      data['startDate'] = entry.startDate;
    }
    if (entry.endDate != null && entry.endDate!.isNotEmpty) {
      data['endDate'] = entry.endDate;
    }
    if (grade != null) data['grade'] = grade;
    if (description != null) data['description'] = description;
    return data;
  }

  Map<String, dynamic> _certificationToPayload(_CertificationEntry entry) {
    final data = <String, dynamic>{
      'id': entry.id,
      'name': entry.nameController.text.trim(),
      'issuer': entry.issuerController.text.trim(),
      'noExpiry': entry.expiryDate == null || entry.expiryDate!.isEmpty,
    };
    final credentialId = _trimOrNull(entry.credentialIdController.text);
    final credentialUrl = _trimOrNull(entry.credentialUrlController.text);
    if (entry.issueDate != null && entry.issueDate!.isNotEmpty) {
      data['issueDate'] = entry.issueDate;
    }
    if (entry.expiryDate != null && entry.expiryDate!.isNotEmpty) {
      data['expiryDate'] = entry.expiryDate;
    }
    if (credentialId != null) data['credentialId'] = credentialId;
    if (credentialUrl != null) data['credentialUrl'] = credentialUrl;
    if (entry.mediaUrl != null && entry.mediaUrl!.isNotEmpty) {
      data['mediaUrl'] = entry.mediaUrl;
    }
    if (entry.mediaMimeType != null && entry.mediaMimeType!.isNotEmpty) {
      data['mediaMimeType'] = entry.mediaMimeType;
    }
    return data;
  }

  Map<String, dynamic> buildCandidateProfilePayload() {
    final minAmount = _parseAmount(_salaryMinController.text);
    final maxAmount = _parseAmount(_salaryMaxController.text);
    if (minAmount != null && maxAmount != null && maxAmount < minAmount) {
      throw const FormatException(
        'Maximum salary must be greater than minimum salary.',
      );
    }

    final experience = _experienceEntries
        .where(
          (entry) =>
              entry.jobTitleController.text.trim().isNotEmpty &&
              entry.companyController.text.trim().isNotEmpty,
        )
        .map(_experienceToPayload)
        .toList();

    final education = _educationEntries
        .where(
          (entry) =>
              entry.institutionController.text.trim().isNotEmpty &&
              entry.degreeController.text.trim().isNotEmpty,
        )
        .map(_educationToPayload)
        .toList();

    final certifications = _certificationEntries
        .where(
          (entry) =>
              entry.nameController.text.trim().isNotEmpty &&
              entry.issuerController.text.trim().isNotEmpty,
        )
        .map(_certificationToPayload)
        .toList();

    final salary = <String, dynamic>{
      'currency': _salaryCurrency,
      'period': _salaryPeriod,
      'isNegotiable': _salaryNegotiable,
    };
    if (minAmount != null) salary['minAmount'] = minAmount;
    if (maxAmount != null) salary['maxAmount'] = maxAmount;

    final payload = <String, dynamic>{
      'preferredRoles': List<String>.from(_preferredRoles),
      'preferredLocations': List<String>.from(_preferredLocations),
      'preferredWorkModes': _preferredWorkModes.toList()..sort(),
      'skills': _skillEntries
          .map(
            (skill) => {
              'id': skill.id,
              'name': skill.name,
              'category': skill.category,
              'proficiency': skill.proficiency,
              'proofs': <Map<String, dynamic>>[],
            },
          )
          .toList(),
      'experience': experience,
      'education': education,
      'certifications': certifications,
      'salary': salary,
      'portfolioLinks': List<String>.from(_portfolioLinks),
      'openToWork': _openToWork,
    };

    final headline = _trimOrNull(_headlineController.text);
    final phone = _trimOrNull(_phoneController.text);
    final location = _trimOrNull(_locationController.text);
    final summary = _trimOrNull(_summaryController.text);
    final linkedin = _trimOrNull(_linkedinController.text);
    final github = _trimOrNull(_githubController.text);
    final portfolioUrl = _trimOrNull(_portfolioUrlController.text);

    if (headline != null) payload['headline'] = headline;
    if (phone != null) payload['phone'] = phone;
    if (location != null) payload['location'] = location;
    if (summary != null) payload['summary'] = summary;
    if (linkedin != null) payload['linkedinUrl'] = linkedin;
    if (github != null) payload['githubUrl'] = github;
    if (portfolioUrl != null) payload['portfolioUrl'] = portfolioUrl;
    if (_selectedDefaultResumeId != null &&
        _selectedDefaultResumeId!.isNotEmpty) {
      payload['defaultResumeId'] = _selectedDefaultResumeId;
    }

    return payload;
  }

  Future<void> _handleSave() async {
    if (widget.onSave == null) return;
    final fullName = widget.fullNameController.text.trim();
    final email = widget.emailAddressController.text.trim();
    final hasInvalidGeneralFields =
        fullName.isEmpty || email.isEmpty || !_isValidEmail(email);

    if (hasInvalidGeneralFields) {
      if (_selectedSubTab != _ProfileSubTab.general) {
        setState(() => _selectedSubTab = _ProfileSubTab.general);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.formKey.currentState?.validate();
        SnackbarUtils.showError(
          context,
          fullName.isEmpty || email.isEmpty
              ? 'Full name and email are required.'
              : 'Please enter a valid email address.',
        );
      });
      return;
    }
    try {
      final payload = buildCandidateProfilePayload();
      await widget.onSave!(payload);
    } on FormatException catch (error) {
      if (!mounted) return;
      SnackbarUtils.showError(context, error.message);
    }
  }

  String get _saveButtonLabel {
    switch (_selectedSubTab) {
      case _ProfileSubTab.general:
        return 'Save Profile Details';
      case _ProfileSubTab.skills:
        return 'Save Skills & Preferences';
      case _ProfileSubTab.experience:
        return 'Save Experience Details';
      case _ProfileSubTab.education:
        return 'Save Education Details';
      case _ProfileSubTab.resume:
        return 'Save Resume Preferences';
      case _ProfileSubTab.certifications:
        return 'Save Certifications';
      case _ProfileSubTab.salary:
        return 'Save Salary Preferences';
    }
  }

  Widget _buildCurrentTab(
    ApplicationState applicationState,
    List<ResumeEntity> resumes,
  ) {
    switch (_selectedSubTab) {
      case _ProfileSubTab.general:
        return _buildGeneralSection();
      case _ProfileSubTab.skills:
        return _buildSkillsSection();
      case _ProfileSubTab.experience:
        return _buildExperienceSection();
      case _ProfileSubTab.education:
        return _buildEducationSection();
      case _ProfileSubTab.resume:
        return _buildResumeSection(applicationState, resumes);
      case _ProfileSubTab.certifications:
        return _buildCertificationsSection();
      case _ProfileSubTab.salary:
        return _buildSalarySection();
    }
  }

  Widget _buildGeneralSection() => UpdateProfileFormCard(
    formKey: widget.formKey,
    fullNameController: widget.fullNameController,
    emailAddressController: widget.emailAddressController,
    profileImageUrl: widget.profileImageUrl,
    onPhotoChanged: widget.onPhotoChanged,
    headlineController: _headlineController,
    phoneController: _phoneController,
    locationController: _locationController,
    summaryController: _summaryController,
    linkedinController: _linkedinController,
    githubController: _githubController,
    portfolioUrlController: _portfolioUrlController,
    isBasicProfile: false,
    embedInCard: false,
  );

  Widget _buildSkillsSection() {
    final categoryCount = _skillEntries
        .map((skill) => skill.category)
        .toSet()
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionFrame(
          title: 'Skills',
          description:
              'Add your skills with proficiency levels. These are shown to recruiters and used for job matching.',
          icon: LucideIcons.code,
          trailing: OutlinedButton.icon(
            onPressed: () {
              SnackbarUtils.showInfo(
                context,
                'AI autofill is not connected on this screen yet.',
              );
            },
            icon: const Icon(LucideIcons.sparkles, size: 14),
            label: const Text('AI Autofill'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_skillEntries.isNotEmpty) ...[
                const _SectionCaption('TECHNICAL'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skillEntries
                      .map(
                        (skill) => _SkillChip(
                          skill: skill,
                          onDeleted: () => _removeSkill(skill.id),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
              _InsetPanel(
                title: 'Add New Skill',
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Skill Name',
                      child: TextFormField(
                        controller: _skillNameController,
                        decoration: _inputDecoration('react'),
                        onFieldSubmitted: (_) => _addSkill(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ResponsiveTwoColumn(
                      left: [
                        _LabeledField(
                          label: 'Category',
                          child: DropdownButtonFormField<String>(
                            initialValue: _skillCategory,
                            decoration: _inputDecoration(),
                            items: const ['Technical', 'Soft', 'Language']
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _skillCategory = value);
                            },
                          ),
                        ),
                      ],
                      right: [
                        _LabeledField(
                          label: 'Proficiency',
                          child: DropdownButtonFormField<String>(
                            initialValue: _skillProficiency,
                            decoration: _inputDecoration(),
                            items:
                                const [
                                      ('beginner', 'Beginner'),
                                      ('intermediate', 'Intermediate'),
                                      ('advanced', 'Advanced'),
                                      ('expert', 'Expert'),
                                      ('master', 'Master'),
                                    ]
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value.$1,
                                        child: Text(value.$2),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _skillProficiency = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: _addSkill,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          icon: const Icon(LucideIcons.plus, size: 14),
                          label: const Text('Add Skill'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _skillNameController.clear();
                              _skillCategory = 'Technical';
                              _skillProficiency = 'intermediate';
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_skillEntries.length} skill${_skillEntries.length == 1 ? '' : 's'} added across '
                '${categoryCount == 0 ? 0 : categoryCount} categor${categoryCount == 1 ? 'y' : 'ies'}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionFrame(
          title: 'Job Preferences',
          description:
              'Set preferred roles, locations, and work modes for better recommendations.',
          icon: LucideIcons.briefcase,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TagInputBlock(
                label: 'Preferred Roles',
                controller: _preferredRoleController,
                hintText: 'Type a preferred role and press comma/enter',
                tags: _preferredRoles,
                addLabel: 'Add Role',
                onChanged: (value) => _handleTagTyping(
                  value: value,
                  controller: _preferredRoleController,
                  target: _preferredRoles,
                  maxItems: 20,
                ),
                onSubmitted: (_) => _addTag(
                  controller: _preferredRoleController,
                  target: _preferredRoles,
                  maxItems: 20,
                ),
                onAddPressed: () => _addTag(
                  controller: _preferredRoleController,
                  target: _preferredRoles,
                  maxItems: 20,
                ),
                onDeleteTag: (tag) => _removeTag(_preferredRoles, tag),
              ),
              const SizedBox(height: 18),
              _TagInputBlock(
                label: 'Preferred Locations',
                controller: _preferredLocationController,
                hintText: 'Type a preferred location and press comma/enter',
                tags: _preferredLocations,
                addLabel: 'Add Location',
                onChanged: (value) => _handleTagTyping(
                  value: value,
                  controller: _preferredLocationController,
                  target: _preferredLocations,
                  maxItems: 20,
                ),
                onSubmitted: (_) => _addTag(
                  controller: _preferredLocationController,
                  target: _preferredLocations,
                  maxItems: 20,
                ),
                onAddPressed: () => _addTag(
                  controller: _preferredLocationController,
                  target: _preferredLocations,
                  maxItems: 20,
                ),
                onDeleteTag: (tag) => _removeTag(_preferredLocations, tag),
              ),
              const SizedBox(height: 18),
              Text(
                'Preferred Work Modes',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children:
                    const [
                      ('remote', 'Remote'),
                      ('onsite', 'Onsite'),
                      ('hybrid', 'Hybrid'),
                    ].map((mode) {
                      final selected = _preferredWorkModes.contains(mode.$1);
                      return ChoiceChip(
                        label: Text(mode.$2),
                        selected: selected,
                        onSelected: (_) => _toggleWorkMode(mode.$1),
                        showCheckmark: false,
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.14,
                        ),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'Select one or more modes to improve role recommendation quality.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionFrame(
          title: 'Work Experience',
          description:
              'Add positions in reverse chronological order. Strong descriptions with measurable impact improve ATS scores and recruiter interest.',
          icon: LucideIcons.briefcaseBusiness,
          trailing: FilledButton.icon(
            onPressed: _addExperience,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Add Experience'),
          ),
          child: const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        ...List.generate(_experienceEntries.length, (index) {
          final entry = _experienceEntries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _InsetPanel(
              title: 'Experience #${index + 1}',
              action: TextButton.icon(
                onPressed: _experienceEntries.length > 1
                    ? () => _removeExperience(index)
                    : null,
                icon: const Icon(LucideIcons.trash2, size: 14),
                label: const Text('Remove'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
              child: Column(
                children: [
                  _ResponsiveTwoColumn(
                    left: [
                      _LabeledField(
                        label: 'Job Title',
                        child: TextFormField(
                          controller: entry.jobTitleController,
                          decoration: _inputDecoration(),
                        ),
                      ),
                      _LabeledField(
                        label: 'Employment Type',
                        child: DropdownButtonFormField<String>(
                          initialValue: entry.employmentType,
                          decoration: _inputDecoration(),
                          items:
                              const [
                                    'Full-time',
                                    'Part-time',
                                    'Contract',
                                    'Internship',
                                    'Freelance',
                                  ]
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => entry.employmentType = value);
                          },
                        ),
                      ),
                    ],
                    right: [
                      _LabeledField(
                        label: 'Company',
                        child: TextFormField(
                          controller: entry.companyController,
                          decoration: _inputDecoration(),
                        ),
                      ),
                      _LabeledField(
                        label: 'Location',
                        child: TextFormField(
                          controller: entry.locationController,
                          decoration: _inputDecoration(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ResponsiveThreeColumn(
                    left: _LabeledField(
                      label: 'Start Date',
                      child: _DateField(
                        value: entry.startDate,
                        placeholder: 'Select start date',
                        onTap: () async {
                          final picked = await _pickDate(entry.startDate);
                          if (!mounted || picked == null) return;
                          setState(() => entry.startDate = picked);
                        },
                      ),
                    ),
                    middle: _LabeledField(
                      label: 'End Date',
                      child: _DateField(
                        value: entry.isCurrent ? null : entry.endDate,
                        placeholder: 'Select end date',
                        enabled: !entry.isCurrent,
                        onTap: () async {
                          if (entry.isCurrent) return;
                          final picked = await _pickDate(entry.endDate);
                          if (!mounted || picked == null) return;
                          setState(() => entry.endDate = picked);
                        },
                      ),
                    ),
                    right: _LabeledField(
                      label: 'Current Role',
                      child: DropdownButtonFormField<String>(
                        initialValue: entry.isCurrent ? 'Yes' : 'No',
                        decoration: _inputDecoration(),
                        items: const ['Yes', 'No']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            entry.isCurrent = value == 'Yes';
                            if (entry.isCurrent) {
                              entry.endDate = null;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: 'Description',
                    child: TextFormField(
                      controller: entry.descriptionController,
                      minLines: 5,
                      maxLines: 7,
                      decoration: _inputDecoration(
                        'Describe your impact. Click "AI Generate" to auto-create bullet points.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        SnackbarUtils.showInfo(
                          context,
                          'AI bullet generation is not connected on this screen yet.',
                        );
                      },
                      icon: const Icon(LucideIcons.sparkles, size: 14),
                      label: const Text('AI Generate'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionFrame(
          title: 'Education',
          description:
              'Add your academic background in reverse chronological order.',
          icon: LucideIcons.graduationCap,
          trailing: FilledButton.icon(
            onPressed: _addEducation,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Add Education'),
          ),
          child: const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        ...List.generate(_educationEntries.length, (index) {
          final entry = _educationEntries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _InsetPanel(
              title: 'Education #${index + 1}',
              action: TextButton.icon(
                onPressed: _educationEntries.length > 1
                    ? () => _removeEducation(index)
                    : null,
                icon: const Icon(LucideIcons.trash2, size: 14),
                label: const Text('Remove'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Institution',
                    child: TextFormField(
                      controller: entry.institutionController,
                      decoration: _inputDecoration(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Degree',
                    child: TextFormField(
                      controller: entry.degreeController,
                      decoration: _inputDecoration(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Field Of Study',
                    child: TextFormField(
                      controller: entry.fieldOfStudyController,
                      decoration: _inputDecoration(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ResponsiveTwoColumn(
                    left: [
                      _LabeledField(
                        label: 'Start Date',
                        child: _DateField(
                          value: entry.startDate,
                          placeholder: 'Select start date',
                          onTap: () async {
                            final picked = await _pickDate(entry.startDate);
                            if (!mounted || picked == null) return;
                            setState(() => entry.startDate = picked);
                          },
                        ),
                      ),
                    ],
                    right: [
                      _LabeledField(
                        label: 'End Date',
                        child: _DateField(
                          value: entry.endDate,
                          placeholder: 'Select end date',
                          onTap: () async {
                            final picked = await _pickDate(entry.endDate);
                            if (!mounted || picked == null) return;
                            setState(() => entry.endDate = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Grade',
                    child: TextFormField(
                      controller: entry.gradeController,
                      decoration: _inputDecoration(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Description',
                    child: TextFormField(
                      controller: entry.highlightsController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: _inputDecoration(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResumeSection(
    ApplicationState applicationState,
    List<ResumeEntity> resumes,
  ) {
    return _SectionFrame(
      title: 'Resume & Documents',
      description:
          'Upload resumes and select a default. The default resume is auto-selected when you apply for jobs and visible to recruiters.',
      icon: LucideIcons.fileText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed:
                applicationState.uploadResumeStatus ==
                    ApplicationLoadStatus.loading
                ? null
                : _pickResumeFile,
            icon:
                applicationState.uploadResumeStatus ==
                    ApplicationLoadStatus.loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.upload, size: 16),
            label: Text(
              applicationState.uploadResumeStatus ==
                      ApplicationLoadStatus.loading
                  ? 'Uploading...'
                  : 'Upload Resume',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'PDF, DOC, DOCX - Max 10 MB',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),
          _LabeledField(
            label: 'Default Resume for Applications',
            child: DropdownButtonFormField<String?>(
              initialValue: _selectedDefaultResumeId,
              decoration: _inputDecoration(),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No default selected'),
                ),
                ...resumes.map(
                  (resume) => DropdownMenuItem<String?>(
                    value: resume.id,
                    child: Text(resume.fileName),
                  ),
                ),
              ],
              onChanged: resumes.isEmpty
                  ? null
                  : (value) => setState(() => _selectedDefaultResumeId = value),
            ),
          ),
          const SizedBox(height: 12),
          const _SectionCaption('YOUR RESUMES'),
          const SizedBox(height: 10),
          if (resumes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('No resumes uploaded yet.'),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: resumes.map((resume) {
                  return _ResumeRow(
                    resume: resume,
                    isDefault: _selectedDefaultResumeId == resume.id,
                    onSetDefault: () {
                      setState(() => _selectedDefaultResumeId = resume.id);
                    },
                    onPreview: () => _previewResume(resume),
                    onDownload: () => _downloadResume(resume),
                    onDelete: () => _deleteResume(resume.id),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),
          _TagInputBlock(
            label: 'Portfolio Links',
            controller: _portfolioLinkController,
            hintText: 'https://github.com/username/project',
            tags: _portfolioLinks,
            addLabel: 'Add Link',
            onChanged: (value) => _handleTagTyping(
              value: value,
              controller: _portfolioLinkController,
              target: _portfolioLinks,
              maxItems: 20,
            ),
            onSubmitted: (_) => _addTag(
              controller: _portfolioLinkController,
              target: _portfolioLinks,
              maxItems: 20,
            ),
            onAddPressed: () => _addTag(
              controller: _portfolioLinkController,
              target: _portfolioLinks,
              maxItems: 20,
            ),
            onDeleteTag: (tag) => _removeTag(_portfolioLinks, tag),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionFrame(
          title: 'Certifications',
          description:
              'Highlight verifiable certifications relevant to your role.',
          icon: LucideIcons.badgeCheck,
          trailing: FilledButton.icon(
            onPressed: _addCertification,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Add Certification'),
          ),
          child: const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        ...List.generate(_certificationEntries.length, (index) {
          final entry = _certificationEntries[index];
          final isUploading = _uploadingCertificationIds.contains(entry.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _InsetPanel(
              title: 'Certification #${index + 1}',
              action: TextButton.icon(
                onPressed: _certificationEntries.length > 1
                    ? () => _removeCertification(index)
                    : null,
                icon: const Icon(LucideIcons.trash2, size: 14),
                label: const Text('Remove'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Certificate Name',
                    child: TextFormField(
                      controller: entry.nameController,
                      decoration: _inputDecoration(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Issuing Organization',
                    child: TextFormField(
                      controller: entry.issuerController,
                      decoration: _inputDecoration(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ResponsiveTwoColumn(
                    left: [
                      _LabeledField(
                        label: 'Issue Date',
                        child: _DateField(
                          value: entry.issueDate,
                          placeholder: 'Select issue date',
                          onTap: () async {
                            final picked = await _pickDate(entry.issueDate);
                            if (!mounted || picked == null) return;
                            setState(() => entry.issueDate = picked);
                          },
                        ),
                      ),
                    ],
                    right: [
                      _LabeledField(
                        label: 'Expiry Date',
                        child: _DateField(
                          value: entry.expiryDate,
                          placeholder: 'Select expiry date',
                          onTap: () async {
                            final picked = await _pickDate(entry.expiryDate);
                            if (!mounted || picked == null) return;
                            setState(() => entry.expiryDate = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Credential URL',
                    child: TextFormField(
                      controller: entry.credentialUrlController,
                      decoration: _inputDecoration(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Credential ID',
                    child: TextFormField(
                      controller: entry.credentialIdController,
                      decoration: _inputDecoration(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: isUploading
                        ? null
                        : () => _pickCertificationFile(entry),
                    icon: isUploading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.upload, size: 14),
                    label: Text(isUploading ? 'Uploading...' : 'Upload File'),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.mediaUrl != null && entry.mediaUrl!.isNotEmpty
                        ? 'File attached and ready to save.'
                        : 'Upload certificate proof as PDF or image for recruiter verification.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSalarySection() {
    return _SectionFrame(
      title: 'Salary Expectations',
      description:
          'Set compensation preferences used for matching and visibility.',
      icon: LucideIcons.dollarSign,
      child: Column(
        children: [
          _ResponsiveThreeColumn(
            left: _LabeledField(
              label: 'Currency',
              child: DropdownButtonFormField<String>(
                initialValue: _salaryCurrency,
                decoration: _inputDecoration(),
                items: const ['NPR', 'USD', 'EUR', 'INR', 'GBP']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _salaryCurrency = value);
                },
              ),
            ),
            middle: _LabeledField(
              label: 'Minimum',
              child: TextFormField(
                controller: _salaryMinController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(),
              ),
            ),
            right: _LabeledField(
              label: 'Maximum',
              child: TextFormField(
                controller: _salaryMaxController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ResponsiveTwoColumn(
            left: [
              _LabeledField(
                label: 'Salary Period',
                child: DropdownButtonFormField<String>(
                  initialValue: _salaryPeriod,
                  decoration: _inputDecoration(),
                  items:
                      const [
                            ('yearly', 'Per Year'),
                            ('monthly', 'Per Month'),
                            ('hourly', 'Per Hour'),
                          ]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value.$1,
                              child: Text(value.$2),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _salaryPeriod = value);
                  },
                ),
              ),
            ],
            right: [
              _LabeledField(
                label: 'Negotiable',
                child: DropdownButtonFormField<bool>(
                  initialValue: _salaryNegotiable,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: false, child: Text('No')),
                    DropdownMenuItem(value: true, child: Text('Yes')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _salaryNegotiable = value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _pickDate(String? currentValue) async {
    final initialDate = currentValue != null
        ? DateTime.tryParse(currentValue) ?? DateTime.now()
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (picked == null) return null;
    return DateFormat('yyyy-MM-dd').format(picked);
  }

  InputDecoration _inputDecoration([String? hint]) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(applicationViewModelProvider);
    final resumes = applicationState.resumesData ?? const <ResumeEntity>[];
    final isCompact = MediaQuery.of(context).size.width < 700;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: _tabMeta.map((tab) {
                    final isSelected = _selectedSubTab == tab.$1;
                    return InkWell(
                      onTap: () => setState(() => _selectedSubTab = tab.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        width: isCompact ? 132 : 204,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab.$3,
                              size: isCompact ? 14 : 15,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textMedium,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tab.$2,
                              style: TextStyle(
                                fontSize: isCompact ? 13 : 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCurrentTab(applicationState, resumes),
            const SizedBox(height: 18),
            if (widget.onSave != null)
              Align(
                alignment: Alignment.centerRight,
                child: MyButton(
                  text: _saveButtonLabel,
                  onPressed: _handleSave,
                  isLoading: widget.isSaving,
                  btnWidth: isCompact ? double.infinity : 230,
                  icon: const Icon(
                    LucideIcons.save,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionFrame extends StatelessWidget {
  const _SectionFrame({
    required this.title,
    required this.description,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 760;
    final headerText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 16 : 22),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: isCompact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: AppColors.textDark),
                  const SizedBox(width: 10),
                  Expanded(child: headerText),
                ],
              ),
              if (trailing != null) ...[
                SizedBox(width: isCompact ? 0 : 12, height: isCompact ? 14 : 0),
                if (isCompact)
                  SizedBox(width: double.infinity, child: trailing!)
                else
                  trailing!,
              ],
            ],
          ),
          if (child is! SizedBox) ...[const SizedBox(height: 18), child],
        ],
      ),
    );
  }
}

class _InsetPanel extends StatelessWidget {
  const _InsetPanel({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 760;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: isCompact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact)
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                )
              else
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (action != null) ...[
                SizedBox(width: isCompact ? 0 : 12, height: isCompact ? 12 : 0),
                if (isCompact)
                  SizedBox(width: double.infinity, child: action!)
                else
                  action!,
              ],
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SectionCaption extends StatelessWidget {
  const _SectionCaption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: Colors.grey.shade700,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ResponsiveTwoColumn extends StatelessWidget {
  const _ResponsiveTwoColumn({required this.left, required this.right});

  final List<Widget> left;
  final List<Widget> right;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 980;
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [...left, const SizedBox(height: 14), ...right],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children:
                left
                    .expand((widget) => [widget, const SizedBox(height: 14)])
                    .toList()
                  ..removeLast(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children:
                right
                    .expand((widget) => [widget, const SizedBox(height: 14)])
                    .toList()
                  ..removeLast(),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveThreeColumn extends StatelessWidget {
  const _ResponsiveThreeColumn({
    required this.left,
    required this.middle,
    required this.right,
  });

  final Widget left;
  final Widget middle;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 1080;
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          left,
          const SizedBox(height: 14),
          middle,
          const SizedBox(height: 14),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: middle),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.enabled = true,
  });

  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          suffixIcon: Icon(
            LucideIcons.calendar,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ),
        child: Text(
          value == null || value!.isEmpty
              ? placeholder
              : DateFormat(
                  'MMM d, yyyy',
                ).format(DateTime.tryParse(value!) ?? DateTime.now()),
          style: TextStyle(
            color: value == null || value!.isEmpty
                ? Colors.grey.shade500
                : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill, required this.onDeleted});

  final _SkillEntry skill;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F2FB),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            skill.name,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label(skill.proficiency),
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onDeleted,
            child: Icon(LucideIcons.x, size: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  static String _label(String value) {
    switch (value) {
      case 'beginner':
        return 'Beginner';
      case 'advanced':
        return 'Advanced';
      case 'expert':
        return 'Expert';
      case 'master':
        return 'Master';
      default:
        return 'Intermediate';
    }
  }
}

class _TagInputBlock extends StatelessWidget {
  const _TagInputBlock({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.tags,
    required this.addLabel,
    required this.onChanged,
    required this.onSubmitted,
    required this.onAddPressed,
    required this.onDeleteTag,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final List<String> tags;
  final String addLabel;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onAddPressed;
  final ValueChanged<String> onDeleteTag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(LucideIcons.plus, size: 14),
          label: Text(addLabel),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => InputChip(
                    label: Text(tag),
                    onDeleted: () => onDeleteTag(tag),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _ResumeRow extends StatelessWidget {
  const _ResumeRow({
    required this.resume,
    required this.isDefault,
    required this.onSetDefault,
    required this.onPreview,
    required this.onDownload,
    required this.onDelete,
  });

  final ResumeEntity resume;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 760;
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
      children: [
        TextButton(
          onPressed: isDefault ? null : onSetDefault,
          child: Text(isDefault ? 'Default' : 'Set Default'),
        ),
        IconButton(
          onPressed: onPreview,
          icon: const Icon(LucideIcons.externalLink, size: 18),
        ),
        IconButton(
          onPressed: onDownload,
          icon: const Icon(LucideIcons.download, size: 18),
        ),
        IconButton(
          onPressed: onDelete,
          color: AppColors.error,
          icon: const Icon(LucideIcons.trash2, size: 18),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      color: Colors.grey.shade100,
                      child: Icon(
                        LucideIcons.file,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resume.fileName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Uploaded ${_formatUploadDate(resume.uploadedAt)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: isCompact
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: actions,
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  color: Colors.grey.shade100,
                  child: Icon(
                    LucideIcons.file,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.fileName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Uploaded ${_formatUploadDate(resume.uploadedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                actions,
              ],
            ),
    );
  }

  static String _formatUploadDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('MMM d, yyyy').format(parsed);
  }
}
