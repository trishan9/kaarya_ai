import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/workspace_settings_widgets.dart';
import 'package:kaarya/features/colleges/presentation/state/college_state.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CollegeSettingsPage extends ConsumerStatefulWidget {
  const CollegeSettingsPage({super.key});

  @override
  ConsumerState<CollegeSettingsPage> createState() =>
      _CollegeSettingsPageState();
}

class _CollegeSettingsPageState extends ConsumerState<CollegeSettingsPage> {
  final _profileFormKey = GlobalKey<FormState>();
  final _inviteFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _institutionTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _inviteEmailController = TextEditingController();
  final _programController = TextEditingController();
  final _yearController = TextEditingController();

  String? _activeCollegeId;
  String? _hydratedSignature;
  String? _inviteCodeOverride;
  String? _logoErrorText;
  File? _selectedLogoFile;
  bool _isSavingProfile = false;
  bool _isInviting = false;
  bool _isResettingCode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionTypeController.dispose();
    _locationController.dispose();
    _inviteEmailController.dispose();
    _programController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await ref.read(collegeDashboardViewModelProvider.notifier).loadWorkspaces();
    final dashboardState = ref.read(collegeDashboardViewModelProvider);
    final workspace =
        dashboardState.selectedWorkspace ??
        ((dashboardState.workspaces?.isNotEmpty ?? false)
            ? dashboardState.workspaces!.first
            : null);
    if (workspace == null) return;
    _activeCollegeId = workspace.collegeId;
    await _loadWorkspaceData(workspace.collegeId);
  }

  Future<void> _loadWorkspaceData(String collegeId) async {
    await Future.wait([
      ref.read(collegeViewModelProvider.notifier).loadCollegeDetail(collegeId),
      ref
          .read(collegeViewModelProvider.notifier)
          .loadStudents(collegeId: collegeId, forceRefresh: true),
      ref
          .read(collegeViewModelProvider.notifier)
          .loadMetrics(collegeId: collegeId, forceRefresh: true),
    ]);
  }

  Future<void> _refreshCurrentWorkspace() async {
    await ref
        .read(collegeDashboardViewModelProvider.notifier)
        .loadWorkspaces(forceRefresh: true);
    final dashboardState = ref.read(collegeDashboardViewModelProvider);
    final workspace =
        dashboardState.selectedWorkspace ??
        ((dashboardState.workspaces?.isNotEmpty ?? false)
            ? dashboardState.workspaces!.first
            : null);
    if (workspace == null) return;
    await _loadWorkspaceData(workspace.collegeId);
  }

  void _hydrateFromDetail() {
    final detail = ref.read(collegeViewModelProvider).collegeDetail;
    if (detail == null) return;

    final signature =
        '${detail.id}|${detail.name}|${detail.institutionType}|${detail.location}|${detail.logo ?? ''}|${detail.inviteCode ?? ''}';
    if (_hydratedSignature == signature) return;

    _hydratedSignature = signature;
    _nameController.text = detail.name;
    _institutionTypeController.text = detail.institutionType;
    _locationController.text = detail.location;
    _inviteCodeOverride = detail.inviteCode;
    _selectedLogoFile = null;
    _logoErrorText = null;
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null || path.isEmpty) return;

    final file = File(path);
    final length = await file.length();
    if (length > 5 * 1024 * 1024) {
      setState(() => _logoErrorText = 'Logo size must be less than 5MB.');
      return;
    }

    if (!mounted) return;
    setState(() {
      _selectedLogoFile = file;
      _logoErrorText = null;
    });
  }

  void _resetLogo() {
    setState(() {
      _selectedLogoFile = null;
      _logoErrorText = null;
    });
  }

  Future<void> _saveCollegeProfile(String collegeId) async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isSavingProfile = true);
    final (college, failure) = await ref
        .read(collegeViewModelProvider.notifier)
        .updateCollege(
          collegeId: collegeId,
          name: _nameController.text.trim(),
          institutionType: _institutionTypeController.text.trim(),
          location: _locationController.text.trim(),
          logoPath: _selectedLogoFile?.path,
        );
    if (!mounted) return;

    setState(() => _isSavingProfile = false);
    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }

    setState(() {
      _selectedLogoFile = null;
      _logoErrorText = null;
      _inviteCodeOverride = college?.inviteCode ?? _inviteCodeOverride;
    });
    await ref
        .read(collegeDashboardViewModelProvider.notifier)
        .loadWorkspaces(forceRefresh: true);
    if (!mounted) return;
    SnackbarUtils.showSuccess(context, 'College settings updated.');
  }

  Future<void> _inviteStudent(String collegeId) async {
    if (!(_inviteFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isInviting = true);
    final failure = await ref
        .read(collegeViewModelProvider.notifier)
        .inviteStudent(
          collegeId: collegeId,
          email: _inviteEmailController.text.trim(),
          program: _programController.text.trim().isEmpty
              ? null
              : _programController.text.trim(),
          year: int.tryParse(_yearController.text.trim()),
        );
    if (!mounted) return;

    setState(() => _isInviting = false);
    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }

    _inviteEmailController.clear();
    _programController.clear();
    _yearController.clear();
    await ref
        .read(collegeViewModelProvider.notifier)
        .loadStudents(collegeId: collegeId, forceRefresh: true);
    if (!mounted) return;
    SnackbarUtils.showSuccess(context, 'Student invited successfully.');
  }

  Future<void> _resetInviteCode(String collegeId) async {
    setState(() => _isResettingCode = true);
    final (newCode, failure) = await ref
        .read(collegeViewModelProvider.notifier)
        .resetInviteCode(collegeId);
    if (!mounted) return;

    setState(() => _isResettingCode = false);
    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }

    setState(() => _inviteCodeOverride = newCode);
    SnackbarUtils.showSuccess(context, 'Invite code refreshed.');
  }

  Future<void> _removeStudent({
    required String collegeId,
    required String studentId,
  }) async {
    final failure = await ref
        .read(collegeViewModelProvider.notifier)
        .removeStudent(collegeId: collegeId, studentId: studentId);
    if (!mounted) return;

    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }
    SnackbarUtils.showSuccess(context, 'Student removed from workspace.');
  }

  Future<void> _copyText(String text, String successMessage) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    SnackbarUtils.showSuccess(context, successMessage);
  }

  String _studentBadgeLabel(String? program, int? year) {
    final parts = <String>[];
    if (program != null && program.trim().isNotEmpty) {
      parts.add(program.trim());
    }
    if (year != null) {
      parts.add('Year $year');
    }
    if (parts.isEmpty) return 'Student';
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(collegeDashboardViewModelProvider);
    final collegeState = ref.watch(collegeViewModelProvider);
    final workspace =
        dashboardState.selectedWorkspace ??
        ((dashboardState.workspaces?.isNotEmpty ?? false)
            ? dashboardState.workspaces!.first
            : null);

    if (workspace != null && _activeCollegeId != workspace.collegeId) {
      _activeCollegeId = workspace.collegeId;
      _hydratedSignature = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadWorkspaceData(workspace.collegeId);
      });
    }

    _hydrateFromDetail();

    if (dashboardState.workspacesStatus == CollegeDashboardLoadStatus.loading &&
        dashboardState.workspaces == null) {
      return const LoaderWidget();
    }

    if (workspace == null) {
      return const WorkspaceEmptyState(
        icon: LucideIcons.graduationCap,
        title: 'No college workspace found',
        description:
            'College settings will appear here once this account is linked to a college workspace.',
      );
    }

    if (collegeState.collegeDetailStatus == CollegeLoadStatus.loading &&
        collegeState.collegeDetail == null) {
      return const LoaderWidget();
    }

    final college = collegeState.collegeDetail;
    final students = collegeState.students ?? const [];
    final metrics = collegeState.metrics;
    final inviteCode = _inviteCodeOverride ?? college?.inviteCode ?? '';
    final pagePadding = MediaQuery.of(context).size.width < 700
        ? const EdgeInsets.fromLTRB(12, 12, 12, 24)
        : const EdgeInsets.fromLTRB(20, 12, 20, 28);

    return RefreshIndicator(
      onRefresh: _refreshCurrentWorkspace,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: pagePadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1080;
            final leftColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PageHeader(
                  title: 'College Settings',
                  icon: LucideIcons.graduationCap,
                ),
                const SizedBox(height: 18),
                WorkspaceSettingsSection(
                  title: 'College Profile',
                  description:
                      'Update college details displayed across student workspace views.',
                  child: Form(
                    key: _profileFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WorkspaceLogoPicker(
                          label: 'College Logo',
                          workspaceName: _nameController.text.trim().isEmpty
                              ? (college?.name ?? workspace.collegeName)
                              : _nameController.text.trim(),
                          remoteLogoUrl: college?.logo ?? workspace.collegeLogo,
                          localLogoFile: _selectedLogoFile,
                          onUploadTap: _pickLogo,
                          onResetTap: _resetLogo,
                          errorText: _logoErrorText,
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'College Name',
                          controller: _nameController,
                          hintText: 'College name',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'College name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'Institution Type',
                          controller: _institutionTypeController,
                          hintText: 'Engineering College',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Institution type is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'Location',
                          controller: _locationController,
                          hintText: 'City, Country',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Location is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        MyButton(
                          onPressed: () =>
                              _saveCollegeProfile(workspace.collegeId),
                          text: 'Save College Changes',
                          isLoading: _isSavingProfile,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                WorkspaceSettingsSection(
                  title: 'Student Access',
                  description: 'Invite students and share workspace access.',
                  child: Form(
                    key: _inviteFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WorkspaceInviteCodePanel(
                          code: inviteCode,
                          onCopyCode: () =>
                              _copyText(inviteCode, 'Invite code copied.'),
                          onCopyLink: () => _copyText(
                            '/college-invites?collegeId=${workspace.collegeId}&inviteCode=${Uri.encodeComponent(inviteCode)}',
                            'Invite link copied.',
                          ),
                          onResetCode: () =>
                              _resetInviteCode(workspace.collegeId),
                          isBusy: _isResettingCode,
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'Student Email',
                          controller: _inviteEmailController,
                          hintText: 'student@college.edu',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Student email is required';
                            }
                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(trimmed)) {
                              return 'Enter a valid student email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'Program (Optional)',
                          controller: _programController,
                          hintText: 'BSc Computer Science',
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'Year (Optional)',
                          controller: _yearController,
                          hintText: '3',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) return null;
                            final year = int.tryParse(trimmed);
                            if (year == null || year < 1 || year > 10) {
                              return 'Enter a valid year between 1 and 10';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        MyButton(
                          onPressed: () => _inviteStudent(workspace.collegeId),
                          text: 'Invite Student',
                          icon: const Icon(
                            LucideIcons.userPlus,
                            size: 16,
                            color: Colors.white,
                          ),
                          isLoading: _isInviting,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );

            final rightColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (metrics != null) ...[
                  WorkspaceSettingsSection(
                    title: 'College Metrics',
                    description:
                        'Snapshot of student and placement activity in this workspace.',
                    child: LayoutBuilder(
                      builder: (context, metricConstraints) {
                        final compact = metricConstraints.maxWidth < 700;
                        final metricTiles = [
                          WorkspaceMetricTile(
                            label: 'Students',
                            value: '${metrics.totalStudents}',
                          ),
                          WorkspaceMetricTile(
                            label: 'Applications',
                            value: '${metrics.totalApplications}',
                          ),
                          WorkspaceMetricTile(
                            label: 'Interviews',
                            value: '${metrics.totalInterviews}',
                          ),
                          WorkspaceMetricTile(
                            label: 'Open Jobs',
                            value: '${metrics.totalJobs}',
                          ),
                          WorkspaceMetricTile(
                            label: 'Avg Interview',
                            value: metrics.averageInterviewScore
                                .toStringAsFixed(1),
                          ),
                        ];

                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children:
                                metricTiles
                                    .expand<Widget>(
                                      (tile) => [
                                        tile,
                                        const SizedBox(height: 12),
                                      ],
                                    )
                                    .toList()
                                  ..removeLast(),
                          );
                        }

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: (metricConstraints.maxWidth - 12) / 2,
                              child: metricTiles[0],
                            ),
                            SizedBox(
                              width: (metricConstraints.maxWidth - 12) / 2,
                              child: metricTiles[1],
                            ),
                            SizedBox(
                              width: (metricConstraints.maxWidth - 24) / 3,
                              child: metricTiles[2],
                            ),
                            SizedBox(
                              width: (metricConstraints.maxWidth - 24) / 3,
                              child: metricTiles[3],
                            ),
                            SizedBox(
                              width: (metricConstraints.maxWidth - 24) / 3,
                              child: metricTiles[4],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                WorkspaceSettingsSection(
                  title: 'Students',
                  description:
                      '${students.length} student${students.length == 1 ? '' : 's'} currently have access to this workspace.',
                  child:
                      collegeState.studentsStatus ==
                              CollegeLoadStatus.loading &&
                          collegeState.students == null
                      ? const Center(child: CircularProgressIndicator())
                      : students.isEmpty
                      ? Text(
                          'No students in this workspace yet.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textLight),
                        )
                      : Column(
                          children: students
                              .map(
                                (member) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: WorkspaceMemberTile(
                                    name: member.name,
                                    email: member.email,
                                    photoUrl: member.photo,
                                    badgeLabel: _studentBadgeLabel(
                                      member.program,
                                      member.year,
                                    ),
                                    onRemove: () => _removeStudent(
                                      collegeId: workspace.collegeId,
                                      studentId: member.userId,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 390, child: leftColumn),
                  const SizedBox(width: 18),
                  Expanded(child: rightColumn),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [leftColumn, const SizedBox(height: 16), rightColumn],
            );
          },
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderStroke),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.textDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
