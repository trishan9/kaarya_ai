import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/workspace_settings_widgets.dart';
import 'package:kaarya/features/companies/presentation/state/company_state.dart';
import 'package:kaarya/features/companies/presentation/view_model/company_view_model.dart';
import 'package:kaarya/features/recruiter/presentation/pages/create_or_join_workspace_page.dart';
import 'package:kaarya/features/recruiter/presentation/view_model/recruiter_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CompanySettingsPage extends ConsumerStatefulWidget {
  const CompanySettingsPage({super.key});

  @override
  ConsumerState<CompanySettingsPage> createState() =>
      _CompanySettingsPageState();
}

class _CompanySettingsPageState extends ConsumerState<CompanySettingsPage> {
  final _profileFormKey = GlobalKey<FormState>();
  final _inviteFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _locationController = TextEditingController();
  final _inviteEmailController = TextEditingController();
  final _designationController = TextEditingController();

  String? _activeCompanyId;
  String? _hydratedSignature;
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
    _industryController.dispose();
    _locationController.dispose();
    _inviteEmailController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await ref.read(recruiterViewModelProvider.notifier).loadWorkspaces();
    final recruiterState = ref.read(recruiterViewModelProvider);
    final workspace =
        recruiterState.selectedWorkspace ??
        ((recruiterState.workspaces?.isNotEmpty ?? false)
            ? recruiterState.workspaces!.first
            : null);
    if (workspace == null) return;
    _activeCompanyId = workspace.companyId;
    await _loadWorkspaceData(workspace.companyId);
  }

  Future<void> _loadWorkspaceData(String companyId) async {
    await Future.wait([
      ref.read(companyViewModelProvider.notifier).loadCompanyDetail(companyId),
      ref
          .read(companyViewModelProvider.notifier)
          .loadRecruiters(companyId: companyId, forceRefresh: true),
    ]);
  }

  Future<void> _refreshCurrentWorkspace() async {
    await ref
        .read(recruiterViewModelProvider.notifier)
        .loadWorkspaces(forceRefresh: true);
    final recruiterState = ref.read(recruiterViewModelProvider);
    final workspace =
        recruiterState.selectedWorkspace ??
        ((recruiterState.workspaces?.isNotEmpty ?? false)
            ? recruiterState.workspaces!.first
            : null);
    if (workspace == null) return;
    await _loadWorkspaceData(workspace.companyId);
  }

  void _hydrateFromDetail() {
    final detail = ref.read(companyViewModelProvider).companyDetail;
    if (detail == null) return;

    final signature =
        '${detail.id}|${detail.name}|${detail.industry}|${detail.location}|${detail.logo ?? ''}';
    if (_hydratedSignature == signature) return;

    _hydratedSignature = signature;
    _nameController.text = detail.name;
    _industryController.text = detail.industry;
    _locationController.text = detail.location;
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

  Future<void> _saveCompanyProfile(String companyId) async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isSavingProfile = true);
    final failure = await ref
        .read(companyViewModelProvider.notifier)
        .updateCompany(
          companyId: companyId,
          fields: {
            'name': _nameController.text.trim(),
            'industry': _industryController.text.trim(),
            'location': _locationController.text.trim(),
            if (_selectedLogoFile != null) 'logoPath': _selectedLogoFile!.path,
          },
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
    });
    await ref
        .read(recruiterViewModelProvider.notifier)
        .loadWorkspaces(forceRefresh: true);
    if (!mounted) return;
    SnackbarUtils.showSuccess(context, 'Company settings updated.');
  }

  Future<void> _inviteRecruiter(String companyId) async {
    if (!(_inviteFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isInviting = true);
    final failure = await ref
        .read(companyViewModelProvider.notifier)
        .inviteRecruiter(
          companyId: companyId,
          email: _inviteEmailController.text.trim(),
          designation: _designationController.text.trim(),
        );
    if (!mounted) return;

    setState(() => _isInviting = false);
    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }

    _inviteEmailController.clear();
    _designationController.clear();
    await ref
        .read(companyViewModelProvider.notifier)
        .loadRecruiters(companyId: companyId, forceRefresh: true);
    if (!mounted) return;
    SnackbarUtils.showSuccess(context, 'Recruiter invited successfully.');
  }

  Future<void> _resetInviteCode(String companyId) async {
    setState(() => _isResettingCode = true);
    final failure = await ref
        .read(companyViewModelProvider.notifier)
        .resetInviteCode(companyId);
    if (!mounted) return;

    setState(() => _isResettingCode = false);
    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }
    SnackbarUtils.showSuccess(context, 'Invite code refreshed.');
  }

  Future<void> _removeRecruiter({
    required String companyId,
    required String recruiterId,
  }) async {
    final failure = await ref
        .read(companyViewModelProvider.notifier)
        .removeRecruiter(companyId: companyId, recruiterId: recruiterId);
    if (!mounted) return;

    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
      return;
    }
    SnackbarUtils.showSuccess(context, 'Recruiter removed from workspace.');
  }

  Future<void> _copyText(String text, String successMessage) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    SnackbarUtils.showSuccess(context, successMessage);
  }

  @override
  Widget build(BuildContext context) {
    final recruiterState = ref.watch(recruiterViewModelProvider);
    final companyState = ref.watch(companyViewModelProvider);
    final currentUserId = ref
        .watch(userSessionServiceProvider)
        .getCurrentUserId();
    final workspace =
        recruiterState.selectedWorkspace ??
        ((recruiterState.workspaces?.isNotEmpty ?? false)
            ? recruiterState.workspaces!.first
            : null);

    if (workspace != null && _activeCompanyId != workspace.companyId) {
      _activeCompanyId = workspace.companyId;
      _hydratedSignature = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadWorkspaceData(workspace.companyId);
      });
    }

    _hydrateFromDetail();

    if (recruiterState.workspacesStatus == RecruiterLoadStatus.loading &&
        recruiterState.workspaces == null) {
      return const LoaderWidget();
    }

    if (workspace == null) {
      return WorkspaceEmptyState(
        icon: LucideIcons.building2,
        title: 'No company workspace found',
        description:
            'Create a new company workspace or join an existing one to manage brand details and recruiter access.',
        action: MyButton(
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => const CreateOrJoinWorkspacePage(),
              ),
            );
            if (result == true && mounted) {
              await _bootstrap();
            }
          },
          text: 'Create or Join Workspace',
          icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
        ),
      );
    }

    if (companyState.companyDetailStatus == CompanyLoadStatus.loading &&
        companyState.companyDetail == null) {
      return const LoaderWidget();
    }

    final company = companyState.companyDetail;
    final recruiters = companyState.recruiters ?? const [];
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
                _PageHeader(
                  title: 'Company Settings',
                  icon: LucideIcons.briefcaseBusiness,
                ),
                const SizedBox(height: 18),
                WorkspaceSettingsSection(
                  title: 'Company Profile',
                  description:
                      'Update the company details and brand logo shown in recruiter workspace views.',
                  child: Form(
                    key: _profileFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WorkspaceLogoPicker(
                          label: 'Company Logo',
                          workspaceName: _nameController.text.trim().isEmpty
                              ? (company?.name ?? workspace.companyName)
                              : _nameController.text.trim(),
                          remoteLogoUrl: company?.logo ?? workspace.companyLogo,
                          localLogoFile: _selectedLogoFile,
                          onUploadTap: _pickLogo,
                          onResetTap: _resetLogo,
                          errorText: _logoErrorText,
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'Company Name',
                          controller: _nameController,
                          hintText: 'Company name',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Company name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'Industry',
                          controller: _industryController,
                          hintText: 'Technology',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Industry is required';
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
                              _saveCompanyProfile(workspace.companyId),
                          text: 'Save Company Changes',
                          isLoading: _isSavingProfile,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                WorkspaceSettingsSection(
                  title: 'Workspace Access',
                  description: 'Invite recruiters and manage workspace access.',
                  child: Form(
                    key: _inviteFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WorkspaceInviteCodePanel(
                          code: company?.inviteCode ?? '',
                          onCopyCode: () => _copyText(
                            company?.inviteCode ?? '',
                            'Invite code copied.',
                          ),
                          onCopyLink: () => _copyText(
                            '/company-invites?companyId=${workspace.companyId}&inviteCode=${Uri.encodeComponent(company?.inviteCode ?? '')}',
                            'Invite link copied.',
                          ),
                          onResetCode: () =>
                              _resetInviteCode(workspace.companyId),
                          isBusy: _isResettingCode,
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'Recruiter Email',
                          controller: _inviteEmailController,
                          hintText: 'recruiter@company.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Recruiter email is required';
                            }
                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(trimmed)) {
                              return 'Enter a valid recruiter email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        WorkspaceSettingsField(
                          label: 'Designation',
                          controller: _designationController,
                          hintText: 'Talent Partner',
                          helperText:
                              'Optional role title for the invited recruiter.',
                        ),
                        const SizedBox(height: 22),
                        MyButton(
                          onPressed: () =>
                              _inviteRecruiter(workspace.companyId),
                          text: 'Invite Recruiter',
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

            final membersColumn = WorkspaceSettingsSection(
              title: 'Current Members',
              description:
                  '${recruiters.length} recruiter${recruiters.length == 1 ? '' : 's'} currently have access to this workspace.',
              child:
                  companyState.recruitersStatus == CompanyLoadStatus.loading &&
                      companyState.recruiters == null
                  ? const Center(child: CircularProgressIndicator())
                  : recruiters.isEmpty
                  ? Text(
                      'No recruiter members found in this workspace yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    )
                  : Column(
                      children: recruiters
                          .map(
                            (member) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: WorkspaceMemberTile(
                                name: member.name,
                                email: member.email,
                                photoUrl: member.photo,
                                badgeLabel: member.designation.isEmpty
                                    ? 'Recruiter'
                                    : member.designation,
                                removeEnabled: member.userId != currentUserId,
                                onRemove: () => _removeRecruiter(
                                  companyId: workspace.companyId,
                                  recruiterId: member.userId,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 380, child: leftColumn),
                  const SizedBox(width: 18),
                  Expanded(child: membersColumn),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [leftColumn, const SizedBox(height: 16), membersColumn],
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
