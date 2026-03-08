import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/features/resume_builder/domain/entities/ats_scan_result_entity.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/presentation/pages/resume_editor_page.dart';
import 'package:kaarya/features/resume_builder/presentation/state/resume_builder_state.dart';
import 'package:kaarya/features/resume_builder/presentation/view_model/resume_builder_view_model.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumeBuilderScreen extends ConsumerStatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  ConsumerState<ResumeBuilderScreen> createState() =>
      _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends ConsumerState<ResumeBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resumeBuilderViewModelProvider.notifier).loadDrafts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: appSurfaceColor(context),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: appTextSecondaryColor(context),
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'AI Builder'),
              Tab(text: 'ATS Scanner'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _AiBuilderTab(onSwitchToAts: () => _tabController.animateTo(1)),
              const _AtsScannerTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AiBuilderTab extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToAts;

  const _AiBuilderTab({required this.onSwitchToAts});

  @override
  ConsumerState<_AiBuilderTab> createState() => _AiBuilderTabState();
}

class _AiBuilderTabState extends ConsumerState<_AiBuilderTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeBuilderViewModelProvider);
    final vm = ref.read(resumeBuilderViewModelProvider.notifier);
    final drafts = state.draftsListData?.drafts ?? [];
    final filtered = _searchQuery.isEmpty
        ? drafts
        : drafts
              .where(
                (d) =>
                    d.title.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _buildHero(context),
            const SizedBox(height: 20),
            if (drafts.isNotEmpty) ...[
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: appSurfaceColor(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: appBorderColor(context)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search resumes...',
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 18,
                      color: appTextSecondaryColor(context),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    hintStyle: TextStyle(
                      color: appTextSecondaryColor(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (state.draftsListStatus == ResumeBuilderLoadStatus.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (state.draftsListStatus == ResumeBuilderLoadStatus.error)
              _buildError(
                state.draftsListErrorMessage,
                () => vm.loadDrafts(forceRefresh: true),
              )
            else if (filtered.isEmpty && _searchQuery.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No resumes match "$_searchQuery"',
                    style: const TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else if (drafts.isEmpty)
              _buildEmptyState(context)
            else
              ...filtered.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _DraftCard(
                    draft: d,
                    onEdit: () => _openEditor(context, draftId: d.id),
                    onDelete: () => _confirmDelete(context, ref, d),
                    onGeneratePdf: () => _generatePdf(context, ref, d.id),
                    onSaveAsResume: () => _saveAsResume(context, ref, d.id),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _openEditor(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(LucideIcons.plus, size: 20),
            label: const Text(
              'New Resume',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'AI-Powered',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Resume Builder AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create ATS-optimized resumes with AI. Get smart suggestions, '
                'beautiful templates, and instant feedback.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => _openEditor(context),
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text(
                          'Create Resume',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: widget.onSwitchToAts,
                        icon: const Icon(LucideIcons.fileCheck, size: 16),
                        label: const Text(
                          'ATS Scan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.fileText,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No resumes yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first AI-powered resume and\nstart applying with confidence.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openEditor(context),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text(
              'Create Your First Resume',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String? msg, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(LucideIcons.circleAlert, size: 36, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            msg ?? 'Failed to load resumes',
            style: const TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {String? draftId}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ResumeEditorPage(draftId: draftId)),
    );
    if (result == true && mounted) {
      ref
          .read(resumeBuilderViewModelProvider.notifier)
          .loadDrafts(forceRefresh: true);
    }
  }

  Future<void> _generatePdf(
    BuildContext context,
    WidgetRef ref,
    String draftId,
  ) async {
    final (result, failure) = await ref
        .read(resumeBuilderViewModelProvider.notifier)
        .generatePdf(draftId);
    if (!context.mounted) return;
    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
    } else if (result != null) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.circleCheck,
                    size: 28,
                    color: Color(0xFF059669),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PDF Generated',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your resume PDF is ready.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: result.pdfUrl));
                          Navigator.pop(context);
                          SnackbarUtils.showSuccess(
                            context,
                            'Link copied to clipboard!',
                          );
                        },
                        icon: const Icon(LucideIcons.copy, size: 15),
                        label: const Text('Copy'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          final uri = Uri.tryParse(result.pdfUrl);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const Icon(LucideIcons.download, size: 15),
                        label: const Text('Download'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _saveAsResume(
    BuildContext context,
    WidgetRef ref,
    String draftId,
  ) async {
    final failure = await ref
        .read(resumeBuilderViewModelProvider.notifier)
        .saveAsResume(draftId);
    if (!context.mounted) return;
    if (failure != null) {
      SnackbarUtils.showError(context, failure.message);
    } else {
      SnackbarUtils.showSuccess(context, 'Saved as your active resume!');
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ResumeDraftEntity draft,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.trash2,
                  size: 24,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Resume?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${draft.title}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      final failure = await ref
          .read(resumeBuilderViewModelProvider.notifier)
          .deleteDraft(draft.id);
      if (!context.mounted) return;
      if (failure != null) {
        SnackbarUtils.showError(context, failure.message);
      } else {
        ref
            .read(resumeBuilderViewModelProvider.notifier)
            .loadDrafts(forceRefresh: true);
        SnackbarUtils.showSuccess(context, 'Resume deleted successfully.');
      }
    }
  }
}

class _DraftCard extends StatelessWidget {
  final ResumeDraftEntity draft;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onGeneratePdf;
  final VoidCallback onSaveAsResume;

  const _DraftCard({
    required this.draft,
    required this.onEdit,
    required this.onDelete,
    required this.onGeneratePdf,
    required this.onSaveAsResume,
  });

  static const _templateColors = {
    'professional': Color(0xFF0471B6),
    'modern': Color(0xFF7C3AED),
    'minimal': Color(0xFF374151),
    'executive': Color(0xFF0F172A),
  };

  @override
  Widget build(BuildContext context) {
    final templateColor = _templateColors[draft.template] ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderStroke2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: templateColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        draft.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: templateColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _capitalize(draft.template),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: templateColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.user,
                      size: 13,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        draft.personalInfo.name.isNotEmpty
                            ? draft.personalInfo.name
                            : 'No name set',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      LucideIcons.clock,
                      size: 13,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _timeAgo(draft.updatedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (draft.experience.isNotEmpty)
                      _chip(
                        LucideIcons.briefcase,
                        '${draft.experience.length} jobs',
                      ),
                    if (draft.education.isNotEmpty)
                      _chip(
                        LucideIcons.graduationCap,
                        '${draft.education.length} edu',
                      ),
                    if (draft.skills.isNotEmpty)
                      _chip(LucideIcons.code, '${draft.skills.length} skills'),
                    if (draft.projects.isNotEmpty)
                      _chip(
                        LucideIcons.folderOpen,
                        '${draft.projects.length} projects',
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _actionBtn(
                        LucideIcons.pencil,
                        'Edit',
                        AppColors.primary,
                        onEdit,
                        filled: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        LucideIcons.fileDown,
                        'PDF',
                        const Color(0xFF059669),
                        onGeneratePdf,
                        filled: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        LucideIcons.save,
                        'Save',
                        const Color(0xFF7C3AED),
                        onSaveAsResume,
                        filled: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 36,
                      width: 36,
                      child: OutlinedButton(
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: AppColors.error,
                        ),
                        child: const Icon(LucideIcons.trash2, size: 16),
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

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textLight),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap, {
    required bool filled,
  }) {
    return SizedBox(
      height: 36,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 14),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 14),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withAlpha(100)),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _timeAgo(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

class _AtsScannerTab extends ConsumerStatefulWidget {
  const _AtsScannerTab();

  @override
  ConsumerState<_AtsScannerTab> createState() => _AtsScannerTabState();
}

class _AtsScannerTabState extends ConsumerState<_AtsScannerTab> {
  String? _filePath;
  String? _fileName;
  String? _selectedDraftId;
  String? _selectedDraftTitle;
  bool _isPreparingDraft = false;

  final _targetRoleCtrl = TextEditingController();
  final _jobDescCtrl = TextEditingController();
  String _expLevel = 'mid';
  bool _showOptions = false;

  static const _expLevels = ['entry', 'junior', 'mid', 'senior', 'lead'];

  @override
  void dispose() {
    _targetRoleCtrl.dispose();
    _jobDescCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeBuilderViewModelProvider);
    final isScanning = state.atsScanStatus == ResumeBuilderLoadStatus.loading;
    final result = state.atsScanData;

    final drafts = state.draftsListData?.drafts ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.fileCheck,
                  size: 20,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATS Resume Scanner',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Upload a PDF or select a draft resume to get an instant ATS score.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (drafts.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDraftPicker(drafts),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or upload a PDF',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _buildUploadSection(),
        const SizedBox(height: 12),
        _buildOptionsToggle(),
        if (_showOptions) ...[const SizedBox(height: 12), _buildOptions()],
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed:
                ((_filePath == null && _selectedDraftId == null) ||
                    isScanning ||
                    _isPreparingDraft)
                ? null
                : _scan,
            icon: (isScanning || _isPreparingDraft)
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(LucideIcons.zap, size: 18),
            label: Text(
              _isPreparingDraft
                  ? 'Preparing PDF...'
                  : isScanning
                  ? 'Analyzing...'
                  : 'Scan My Resume',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.borderStroke,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (state.atsScanErrorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.circleAlert,
                  size: 18,
                  color: AppColors.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.atsScanErrorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (result != null) ...[
          const SizedBox(height: 24),
          _buildResults(result),
        ],
      ],
    );
  }

  Widget _buildUploadSection() {
    final hasFile = _filePath != null;
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: hasFile ? AppColors.bgSecondary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? AppColors.primary : AppColors.borderStroke,
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: hasFile
                    ? AppColors.primary.withAlpha(20)
                    : AppColors.bgLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFile ? LucideIcons.fileCheck : LucideIcons.upload,
                size: 26,
                color: hasFile ? AppColors.primary : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasFile ? _fileName! : 'Upload Your Resume',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: hasFile ? AppColors.primary : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              hasFile ? 'Tap to change file' : 'PDF files only • Tap to browse',
              style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
            ),
            if (hasFile) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(() {
                  _filePath = null;
                  _fileName = null;
                }),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.x, size: 14, color: AppColors.error),
                    SizedBox(width: 4),
                    Text(
                      'Remove file',
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showOptions = !_showOptions),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.settings2,
              size: 16,
              color: AppColors.textLight,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Scan options (optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              _showOptions ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 16,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Target Role (optional)'),
          const SizedBox(height: 6),
          _input(
            controller: _targetRoleCtrl,
            hint: 'e.g. Senior Frontend Engineer',
          ),
          const SizedBox(height: 14),
          _label('Experience Level'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _expLevels.map((lvl) {
              final selected = _expLevel == lvl;
              return GestureDetector(
                onTap: () => setState(() => _expLevel = lvl),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.bgLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.borderStroke,
                    ),
                  ),
                  child: Text(
                    _capitalize(lvl),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _label('Job Description (optional)'),
          const SizedBox(height: 6),
          _input(
            controller: _jobDescCtrl,
            hint: 'Paste the job description for more targeted analysis...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildResults(AtsScanResultEntity result) {
    final score = result.overallScore.clamp(0, 100).toDouble();
    final scoreInt = score.toInt();
    final categories = _categoryList(result);
    final bandColor = _scoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'ATS Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: bandColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: bandColor.withAlpha(80)),
              ),
              child: Text(
                'Overall $scoreInt/100',
                style: TextStyle(
                  color: bandColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (result.classificationReason != null &&
            result.classificationReason!.isNotEmpty &&
            !result.isNotResume) ...[
          const SizedBox(height: 6),
          Text(
            result.classificationReason!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF059669),
              height: 1.4,
            ),
          ),
        ],
        if (result.isNotResume) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.circleAlert,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.classificationReason ??
                        'This document does not appear to be a resume.',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _statsBox(
                'Overall',
                '$scoreInt/100',
                const Color(0xFF0471B6),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statsBox(
                'Strengths',
                '${result.totalStrengths}',
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statsBox(
                'To Improve',
                '${result.totalImprovements}',
                const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderStroke2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overall Readiness',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CustomPaint(
                      painter: _ScoreArcPainter(score / 100, bandColor),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$scoreInt',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const Text(
                              'out of 100',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FEEDBACK SUMMARY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF10B981).withAlpha(60),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Strengths',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ),
                              Text(
                                '${result.totalStrengths}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withAlpha(60),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'To Improve',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                              Text(
                                '${result.totalImprovements}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderStroke2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              if (categories.isEmpty)
                const Text(
                  'No category data available.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                )
              else
                ...categories.map(
                  (c) => _scoreBar(c.$1, c.$2.score, _scoreColor(c.$2.score)),
                ),
            ],
          ),
        ),
        if (categories.isNotEmpty)
          ...categories.map((c) => _categoryTipsCard(c.$1, c.$2)),
      ],
    );
  }

  Widget _statsBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<(String, AtsScanCategoryEntity)> _categoryList(AtsScanResultEntity r) {
    return [
      if (r.ats != null) ('ATS Suitability', r.ats!),
      if (r.toneAndStyle != null) ('Tone & Style', r.toneAndStyle!),
      if (r.content != null) ('Content Quality', r.content!),
      if (r.structure != null) ('Structure', r.structure!),
      if (r.skills != null) ('Skills Relevance', r.skills!),
    ];
  }

  Color _scoreColor(double score) {
    if (score >= 75) return const Color(0xFF10B981);
    if (score >= 55) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Widget _scoreBar(String label, double score, Color color) {
    final clamped = score.clamp(0, 100).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
              ),
              Text(
                '${clamped.toInt()}/100',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clamped / 100,
              minHeight: 7,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTipsCard(String title, AtsScanCategoryEntity category) {
    final score = category.score.clamp(0, 100).toDouble();
    final accentColor = _scoreColor(score);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStroke2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: accentColor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 14, 14, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${score.toInt()}/100',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 14, 14),
                        child: category.tips.isEmpty
                            ? const Text(
                                'No suggestions available for this category.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              )
                            : Column(
                                children: category.tips.map((tip) {
                                  final isGood = tip.isGood;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 1,
                                          ),
                                          child: Icon(
                                            isGood
                                                ? LucideIcons.circleCheck
                                                : LucideIcons.circleAlert,
                                            size: 16,
                                            color: isGood
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF59E0B),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tip.tip,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.textDark,
                                                  height: 1.4,
                                                ),
                                              ),
                                              if (tip.explanation != null &&
                                                  tip
                                                      .explanation!
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  tip.explanation!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textMedium,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
  );

  Widget _input({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMedium, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _filePath = result.files.first.path;
        _fileName = result.files.first.name;
      });
    }
  }

  Widget _buildDraftPicker(List<ResumeDraftEntity> drafts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan from your drafts',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: drafts.map((d) {
              final isSelected = _selectedDraftId == d.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedDraftId = null;
                      _selectedDraftTitle = null;
                    } else {
                      _selectedDraftId = d.id;
                      _selectedDraftTitle = d.title;
                      _filePath = null;
                      _fileName = null;
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderStroke,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? LucideIcons.circleCheck
                              : LucideIcons.fileText,
                          size: 15,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          d.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedDraftId != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.info,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A PDF will be generated from "$_selectedDraftTitle" before scanning.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _scan() async {
    final vm = ref.read(resumeBuilderViewModelProvider.notifier);

    String? scanPath = _filePath;

    if (_selectedDraftId != null && scanPath == null) {
      setState(() => _isPreparingDraft = true);
      final (pdfResult, pdfFailure) = await vm.generatePdf(_selectedDraftId!);
      if (!mounted) return;
      if (pdfFailure != null || pdfResult == null) {
        setState(() => _isPreparingDraft = false);
        SnackbarUtils.showError(
          context,
          pdfFailure?.message ?? 'Failed to generate PDF',
        );
        return;
      }
      scanPath = await _downloadPdfToTemp(pdfResult.pdfUrl);
      if (!mounted) return;
      setState(() => _isPreparingDraft = false);
      if (scanPath == null) {
        SnackbarUtils.showError(context, 'Failed to download PDF for scanning');
        return;
      }
    }

    if (scanPath == null) return;

    await vm.atsScan(
      filePath: scanPath,
      targetRole: _targetRoleCtrl.text.trim().isEmpty
          ? null
          : _targetRoleCtrl.text.trim(),
      experienceLevel: _expLevel,
      jobDescription: _jobDescCtrl.text.trim().isEmpty
          ? null
          : _jobDescCtrl.text.trim(),
    );
  }

  Future<String?> _downloadPdfToTemp(String url) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'ats_scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${tempDir.path}/$fileName';
      await Dio().download(url, filePath);
      return File(filePath).existsSync() ? filePath : null;
    } catch (_) {
      return null;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _ScoreArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ScoreArcPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    const startAngle = 135 * math.pi / 180;
    const totalSweep = 270 * math.pi / 180;

    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      bgPaint,
    );

    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        totalSweep * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreArcPainter old) =>
      old.progress != progress || old.color != color;
}
