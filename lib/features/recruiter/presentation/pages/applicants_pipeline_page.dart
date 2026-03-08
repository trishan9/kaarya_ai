import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/entities/job_applicant_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ApplicantsPipelinePage extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;

  const ApplicantsPipelinePage({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  ConsumerState<ApplicantsPipelinePage> createState() =>
      _ApplicantsPipelinePageState();
}

class _ApplicantsPipelinePageState
    extends ConsumerState<ApplicantsPipelinePage> {
  List<JobApplicantEntity>? _applicants;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final repo = ref.read(applicationRepositoryProvider);
    final result = await repo.getJobApplicants(
      jobId: widget.jobId,
      page: 1,
      size: 50,
    );

    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
        _applicants = null;
      }),
      (data) => setState(() {
        _loading = false;
        _applicants = data.applicants;
        _error = null;
      }),
    );
  }

  void _openApplicantSheet(JobApplicantEntity applicant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: _ApplicantDetail(
                jobId: widget.jobId,
                applicant: applicant,
                onUpdated: (closeSheet) {
                  _loadApplicants();
                  if (closeSheet && context.mounted)
                    Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Applicants Pipeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.jobTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const LoaderWidget()
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _loadApplicants)
          : _applicants == null || _applicants!.isEmpty
          ? _EmptyState()
          : _ApplicantList(
              applicants: _applicants!,
              onSelect: _openApplicantSheet,
            ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.circleAlert,
                size: 40,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.users,
                size: 48,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No applications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Applications for this role will appear here once candidates apply.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textLight,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicantList extends StatelessWidget {
  const _ApplicantList({required this.applicants, required this.onSelect});

  final List<JobApplicantEntity> applicants;
  final ValueChanged<JobApplicantEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgLight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: applicants.length,
        itemBuilder: (_, i) {
          final a = applicants[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderStroke2),
            ),
            child: InkWell(
              onTap: () => onSelect(a),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Avatar(name: a.candidateName),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.candidateName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (a.candidateEmail != null)
                                Text(
                                  a.candidateEmail!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMedium,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatStatus(a.status),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Applied ${_formatDate(a.appliedAt)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatStatus(String s) {
    if (s.isEmpty) return 'Applied';
    return s
        .split('_')
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _formatDate(String d) {
    final dt = DateTime.tryParse(d);
    if (dt == null) return d;
    return '${dt.day} ${_month(dt.month)} ${dt.year}';
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMedium,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final parts = name.split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.isNotEmpty
        ? name[0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.bgSecondary,
      child: Text(
        initials,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

const _statusOptions = [
  'applied',
  'reviewing',
  'shortlisted',
  'interview_scheduled',
  'accepted',
  'rejected',
  'withdrawn',
];

class _ApplicantDetail extends ConsumerStatefulWidget {
  const _ApplicantDetail({
    required this.jobId,
    required this.applicant,
    this.onUpdated,
  });

  final String jobId;
  final JobApplicantEntity applicant;
  final void Function(bool closeSheet)? onUpdated;

  @override
  ConsumerState<_ApplicantDetail> createState() => _ApplicantDetailState();
}

class _ApplicantDetailState extends ConsumerState<_ApplicantDetail> {
  late String _selectedStatus;
  DateTime? _interviewDate;
  final _interviewNoteController = TextEditingController();
  bool _isSavingStatus = false;
  bool _isSavingInvite = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.applicant.status.isEmpty
        ? 'applied'
        : widget.applicant.status;
    if (widget.applicant.interviewDate != null) {
      _interviewDate = DateTime.tryParse(widget.applicant.interviewDate!);
    }
    _interviewNoteController.text = widget.applicant.interviewNote ?? '';
  }

  @override
  void dispose() {
    _interviewNoteController.dispose();
    super.dispose();
  }

  Future<void> _trackResumeActivity(WidgetRef ref, String action) async {
    try {
      await ref
          .read(applicationRepositoryProvider)
          .updateResumeActivity(
            jobId: widget.jobId,
            applicationId: widget.applicant.id,
            action: action,
          );
    } catch (_) {}
  }

  Future<void> _downloadResume(
    BuildContext context,
    WidgetRef ref,
    String? resumeUrl,
    String? fileName,
  ) async {
    if (resumeUrl == null || resumeUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume URL not available')),
        );
      }
      return;
    }
    unawaited(_trackResumeActivity(ref, 'downloaded'));
    await _downloadAndOpen(context, resumeUrl, fileName);
  }

  Future<void> _downloadAndOpen(
    BuildContext context,
    String resumeUrl,
    String? fileName,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final ext = fileName != null && fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '.pdf';
      final savePath = '${dir.path}/resume_${widget.applicant.id}$ext';
      await Dio().download(resumeUrl, savePath);
      final result = await OpenFilex.open(savePath);
      if (context.mounted) {
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opened ${fileName ?? 'resume'}'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (result.type == ResultType.noAppToOpen) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No app to open PDF. Install a PDF viewer.'),
            ),
          );
        } else if (result.message.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.message)));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not download: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResume =
        widget.applicant.resumeUrl != null &&
        widget.applicant.resumeUrl!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(name: widget.applicant.candidateName),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.applicant.candidateName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (widget.applicant.candidateEmail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.applicant.candidateEmail!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMedium,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (hasResume)
            OutlinedButton.icon(
              onPressed: () => _downloadResume(
                context,
                ref,
                widget.applicant.resumeUrl,
                widget.applicant.resumeFileName,
              ),
              icon: const Icon(LucideIcons.download, size: 16),
              label: const Text('Download'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          if (widget.applicant.resumeFileName != null) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: hasResume
                  ? () => _downloadResume(
                      context,
                      ref,
                      widget.applicant.resumeUrl,
                      widget.applicant.resumeFileName,
                    )
                  : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.fileText,
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
                            widget.applicant.resumeFileName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.applicant.resumeViewCount} views • ${widget.applicant.resumeDownloadCount} downloads',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasResume)
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: AppColors.textMedium,
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (widget.applicant.coverLetter != null &&
              widget.applicant.coverLetter!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: 'Cover Letter'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Text(
                widget.applicant.coverLetter!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader(title: 'Candidate Profile'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.briefcase,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Open to work: ${widget.applicant.candidateOpenToWork ? 'Yes' : 'No'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Update Status'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.bgTertiary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
                    ),
                  ),
                  items: _statusOptions
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(_formatStatus(s)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedStatus = v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: MyButton(
                  onPressed: () {
                    _saveStatus();
                  },
                  text: 'Update Status',
                  btnWidth: 140,
                  isLoading: _isSavingStatus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Send Interview Invite'),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickInterviewDateTime,
            borderRadius: BorderRadius.circular(10),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: 'Select Interview date and time',
                filled: true,
                fillColor: AppColors.bgTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
                ),
              ),
              child: Text(
                _interviewDate != null
                    ? '${_formatDate(_interviewDate!.toIso8601String())} ${_formatTime(_interviewDate!)}'
                    : 'Select Interview date and time',
                style: TextStyle(
                  color: _interviewDate != null
                      ? AppColors.textDark
                      : AppColors.textMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _interviewNoteController,
            decoration: InputDecoration(
              hintText:
                  'Interview note, meeting link, or recruiter instructions',
              filled: true,
              fillColor: AppColors.bgTertiary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          MyButton(
            onPressed: () {
              _sendInterviewInvite();
            },
            text: 'Send Interview Invite',
            icon: const Icon(LucideIcons.send, size: 18, color: Colors.white),
            isLoading: _isSavingInvite,
          ),
        ],
      ),
    );
  }

  String _formatStatus(String s) {
    if (s.isEmpty) return 'Applied';
    return s
        .split('_')
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _formatDate(String d) {
    final dt = DateTime.tryParse(d);
    if (dt == null) return d;
    return '${dt.day} ${_month(dt.month)} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }

  Future<void> _saveStatus() async {
    setState(() => _isSavingStatus = true);
    final result = await ref
        .read(applicationRepositoryProvider)
        .updateApplication(
          jobId: widget.jobId,
          applicationId: widget.applicant.id,
          status: _selectedStatus,
        );
    if (!mounted) return;
    setState(() => _isSavingStatus = false);
    result.fold(
      (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application status updated.'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onUpdated?.call(false);
      },
    );
  }

  Future<void> _pickInterviewDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _interviewDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _interviewDate != null
          ? TimeOfDay.fromDateTime(_interviewDate!)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (!mounted || time == null) return;
    setState(() {
      _interviewDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _sendInterviewInvite() async {
    if (_interviewDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select interview date and time first.')),
      );
      return;
    }
    setState(() => _isSavingInvite = true);
    final result = await ref
        .read(applicationRepositoryProvider)
        .updateApplication(
          jobId: widget.jobId,
          applicationId: widget.applicant.id,
          status: 'interview_scheduled',
          interviewScheduledAt: _interviewDate!,
          interviewNote: _interviewNoteController.text.trim().isEmpty
              ? null
              : _interviewNoteController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSavingInvite = false);
    result.fold(
      (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interview invite sent.'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onUpdated?.call(true);
      },
    );
  }
}
