import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';
import 'package:kaarya/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';

class ApplyToJobPage extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String? companyLogo;

  const ApplyToJobPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogo,
  });

  @override
  ConsumerState<ApplyToJobPage> createState() => _ApplyToJobPageState();
}

class _ApplyToJobPageState extends ConsumerState<ApplyToJobPage> {
  final _coverLetterController = TextEditingController();
  final List<TextEditingController> _portfolioControllers = [
    TextEditingController(),
  ];
  String? _selectedResumeId;
  PlatformFile? _pickedFile;
  bool _isSubmitting = false;
  bool _defaultsApplied = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = ref.read(dashboardViewModelProvider.notifier);
      vm.loadMyResumes();
      vm.loadProfilePreferences();
    });
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    for (final c in _portfolioControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyDefaults(List<ResumeEntity> resumes, ProfilePreferences? prefs) {
    if (_defaultsApplied || prefs == null) return;
    _defaultsApplied = true;

    Future.microtask(() {
      if (!mounted) return;
      setState(() {
        if (prefs.defaultResumeId != null &&
            resumes.any((r) => r.id == prefs.defaultResumeId)) {
          _selectedResumeId = prefs.defaultResumeId;
        } else if (resumes.isNotEmpty) {
          _selectedResumeId = resumes.first.id;
        }

        final links = <String>[];
        if (prefs.portfolioUrl != null && prefs.portfolioUrl!.isNotEmpty) {
          links.add(prefs.portfolioUrl!);
        }
        if (prefs.linkedinUrl != null && prefs.linkedinUrl!.isNotEmpty) {
          links.add(prefs.linkedinUrl!);
        }
        if (prefs.githubUrl != null && prefs.githubUrl!.isNotEmpty) {
          links.add(prefs.githubUrl!);
        }
        for (final l in prefs.portfolioLinks) {
          if (!links.contains(l)) links.add(l);
        }

        if (links.isNotEmpty) {
          for (final c in _portfolioControllers) {
            c.dispose();
          }
          _portfolioControllers.clear();
          for (final link in links) {
            _portfolioControllers.add(TextEditingController(text: link));
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final resumes = state.resumesData ?? [];
    final prefs = state.profilePrefs;

    if (!_defaultsApplied &&
        resumes.isNotEmpty &&
        state.resumesStatus == DashboardLoadStatus.loaded) {
      _applyDefaults(resumes, prefs);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Form'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJobHeader(),
            const SizedBox(height: 24),
            _buildResumeSection(resumes, state.resumesStatus),
            const SizedBox(height: 24),
            _buildUploadSection(),
            const SizedBox(height: 24),
            _buildCoverLetterSection(),
            const SizedBox(height: 24),
            _buildPortfolioSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Application'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    final logo = widget.companyLogo;
    final hasLogo = logo != null && logo.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: hasLogo
                ? Image.network(
                    logo,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _companyInitials(),
                  )
                : _companyInitials(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.jobTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.companyName,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _companyInitials() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.companyName.isNotEmpty
            ? widget.companyName[0].toUpperCase()
            : 'C',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildResumeSection(
    List<ResumeEntity> resumes,
    DashboardLoadStatus status,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Existing Resume',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select from your uploaded resumes',
          style: TextStyle(color: AppColors.textMedium, fontSize: 13),
        ),
        const SizedBox(height: 10),
        if (status == DashboardLoadStatus.loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: LoaderWidget(),
          )
        else if (resumes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderStroke2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(LucideIcons.fileX, size: 36, color: AppColors.textMedium),
                const SizedBox(height: 8),
                const Text(
                  'No resumes uploaded yet',
                  style: TextStyle(color: AppColors.textMedium),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Upload from Settings > Profile',
                  style: TextStyle(color: AppColors.textMedium, fontSize: 12),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF0F0F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: resumes.asMap().entries.map((entry) {
                final index = entry.key;
                final resume = entry.value;
                final isSelected = _selectedResumeId == resume.id;
                final isLast = index == resumes.length - 1;

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (_selectedResumeId == resume.id) {
                        _selectedResumeId = null;
                      } else {
                        _selectedResumeId = resume.id;
                        _pickedFile = null;
                      }
                    });
                  },
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(10) : Radius.zero,
                    bottom: isLast ? const Radius.circular(10) : Radius.zero,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.bgSecondary.withAlpha(80)
                          : null,
                      border: isLast
                          ? null
                          : const Border(
                              bottom: BorderSide(color: Color(0xFFF5F5F5)),
                            ),
                    ),
                    child: Row(
                      children: [
                        _radioIndicator(isSelected),
                        const SizedBox(width: 12),
                        Icon(
                          LucideIcons.fileText,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resume.fileName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Uploaded ${resume.uploadedAt}',
                                style: const TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (resume.atsScore != null) ...[
                          const SizedBox(width: 8),
                          _atsChip(resume.atsScore!),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _radioIndicator(bool selected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.borderStroke,
          width: selected ? 2 : 1.5,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _atsChip(double score) {
    final rounded = score.round();
    Color bg;
    Color fg;
    if (rounded >= 80) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (rounded >= 60) {
      bg = const Color(0xFFFEF3C6);
      fg = const Color(0xFF92400E);
    } else {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.sparkles, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            'ATS $rounded%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Resume / CV',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          _selectedResumeId != null
              ? 'Or upload a new file instead'
              : 'Attach a resume to your application',
          style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _pickedFile != null
                    ? AppColors.primary.withAlpha(80)
                    : AppColors.borderStroke2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _pickedFile != null
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          LucideIcons.fileCheck,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pickedFile!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatFileSize(_pickedFile!.size),
                              style: const TextStyle(
                                color: AppColors.textMedium,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _pickedFile = null),
                        icon: Icon(
                          LucideIcons.x,
                          size: 18,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(
                        LucideIcons.cloudUpload,
                        size: 36,
                        color: AppColors.textMedium,
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: AppColors.textMedium),
                          children: [
                            const TextSpan(text: 'Tap to upload, or '),
                            TextSpan(
                              text: 'choose here',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Supported files: PDF, DOC, DOCX',
                        style: TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverLetterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Cover Letter',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _coverLetterController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Write your cover letter here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Link Portfolio',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Text(' *', style: TextStyle(color: AppColors.error)),
            const Spacer(),
            GestureDetector(
              onTap: _addPortfolioField,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgSecondary,
                  border: Border.all(color: AppColors.primary.withAlpha(40)),
                ),
                child: Icon(
                  LucideIcons.plus,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_portfolioControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _portfolioControllers[index],
                    decoration: InputDecoration(
                      hintText: 'https://www.example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (_portfolioControllers.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _removePortfolioField(index),
                    icon: Icon(
                      LucideIcons.trash2,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  void _addPortfolioField() {
    setState(() => _portfolioControllers.add(TextEditingController()));
  }

  void _removePortfolioField(int index) {
    setState(() {
      _portfolioControllers[index].dispose();
      _portfolioControllers.removeAt(index);
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _selectedResumeId = null;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _submit() async {
    final portfolioLinks = _portfolioControllers
        .map((c) => c.text.trim())
        .where((link) => link.isNotEmpty)
        .toList();

    setState(() => _isSubmitting = true);
    final pickedFile = _pickedFile;
    final failure = await ref
        .read(dashboardViewModelProvider.notifier)
        .applyToJob(
          widget.jobId,
          resumeId: _selectedResumeId,
          resumeFilePath: pickedFile?.path,
          resumeBytes: pickedFile?.bytes,
          resumeFilename: pickedFile?.name,
          coverLetter: _coverLetterController.text.trim(),
          portfolioLinks: portfolioLinks.isEmpty ? null : portfolioLinks,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
    } else {
      SnackbarUtils.showSuccess(context, 'Application submitted successfully!');
      Navigator.of(context).pop(true);
    }
  }
}
