// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/resources/presentation/view_model/resource_view_model.dart';
import 'package:kaarya/features/resources/presentation/state/resource_state.dart';

void showCreateCourseSheet(BuildContext context) {
  // Capture the parent ScaffoldMessenger before the sheet opens so we can
  // show snackbars on the parent scaffold reliably (even after the sheet pops).
  final messenger = ScaffoldMessenger.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateCourseSheet(parentMessenger: messenger),
  );
}

class _CreateCourseSheet extends ConsumerStatefulWidget {
  final ScaffoldMessengerState parentMessenger;

  const _CreateCourseSheet({required this.parentMessenger});

  @override
  ConsumerState<_CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends ConsumerState<_CreateCourseSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _rolesController = TextEditingController();
  final _jdController = TextEditingController();
  final _promptController = TextEditingController();
  final _chapterCountController = TextEditingController(text: '6');

  String _generationMode = 'learn';
  String _difficulty = 'intermediate';
  String _visibility = 'private';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rolesController.dispose();
    _jdController.dispose();
    _promptController.dispose();
    _chapterCountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final roles = _rolesController.text
        .split(',')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    if (roles.isEmpty) {
      widget.parentMessenger.showSnackBar(
        const SnackBar(content: Text('Please enter at least one target role.')),
      );
      return;
    }

    final chapterCount = int.tryParse(_chapterCountController.text.trim()) ?? 6;

    final failure = await ref
        .read(resourceViewModelProvider.notifier)
        .createCourse(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          category: _rolesController.text.split(',').first.trim(),
          generationMode: _generationMode,
          difficulty: _difficulty,
          targetRoles: roles,
          chapterCount: chapterCount.clamp(1, 14),
          visibility: _visibility,
          jobDescriptionContext: _jdController.text.trim().isEmpty
              ? null
              : _jdController.text.trim(),
          promptContext: _promptController.text.trim().isEmpty
              ? null
              : _promptController.text.trim(),
        );

    if (!mounted) return;

    if (failure != null) {
      widget.parentMessenger.showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      Navigator.of(context).pop();
      widget.parentMessenger.showSnackBar(
        const SnackBar(
          content: Text('Course generated successfully!'),
          backgroundColor: AppColors.success2,
        ),
      );
      ref
          .read(resourceViewModelProvider.notifier)
          .loadCourses(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourceViewModelProvider);
    final isGenerating =
        state.createCourseStatus == ResourceLoadStatus.loading;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle ─────────────────────────────────────────────────────────
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderStroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    LucideIcons.sparkles,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate New Course',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: 0,
                        ),
                      ),
                      Text(
                        'AI will build chapters & content for you',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppColors.textLight,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderStroke2),
          // ── Form ───────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Mode Toggle ──────────────────────────────────────────
                    _label('Course Type', required: true),
                    const SizedBox(height: 8),
                    _modeToggle(),
                    const SizedBox(height: 20),

                    // ── Title ────────────────────────────────────────────────
                    _label('Course Title', required: true),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      decoration: _inputDecoration(
                        _generationMode == 'learn'
                            ? 'e.g. Transformers: From Fundamentals to Production'
                            : 'e.g. Backend Engineer Interview Sprint',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Title is required'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Target Roles ─────────────────────────────────────────
                    _label('Target Roles', required: true),
                    const SizedBox(height: 4),
                    Text(
                      'Comma-separated, e.g. "AI Engineer, ML Engineer"',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _rolesController,
                      textCapitalization: TextCapitalization.words,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      decoration: _inputDecoration('AI Engineer, ML Engineer'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'At least one role is required'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Difficulty + Chapters Row ────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Difficulty'),
                              const SizedBox(height: 6),
                              _dropdown(
                                value: _difficulty,
                                items: [
                                  DropdownMenuItem(
                                    value: 'beginner',
                                    child: Text(
                                      'Beginner',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'intermediate',
                                    child: Text(
                                      'Intermediate',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'advanced',
                                    child: Text(
                                      'Advanced',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (v) => setState(
                                  () => _difficulty = v ?? 'intermediate',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Chapters'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _chapterCountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                                decoration: _inputDecoration('6'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Visibility ───────────────────────────────────────────
                    _label('Visibility'),
                    const SizedBox(height: 6),
                    _dropdown(
                      value: _visibility,
                      items: [
                        DropdownMenuItem(
                          value: 'private',
                          child: Text(
                            'Private — only you can see',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'public',
                          child: Text(
                            'Public — everyone can see',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _visibility = v ?? 'private'),
                    ),
                    const SizedBox(height: 20),

                    // ── Description (Optional) ───────────────────────────────
                    _label('Description'),
                    const SizedBox(height: 4),
                    Text(
                      'Optional: Describe what should be covered and how deep it should go.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      decoration: _inputDecoration(
                        _generationMode == 'learn'
                            ? 'What topics? How deep?'
                            : 'What interview patterns?',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Job Description Context (Optional) ───────────────────
                    _label('Job Description Context'),
                    const SizedBox(height: 4),
                    Text(
                      'Optional: Paste role expectations, responsibilities, or required skills.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _jdController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      decoration: _inputDecoration(
                        'Paste job description or role requirements...',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Additional AI Instructions (Optional) ────────────────
                    _label('Additional Instructions'),
                    const SizedBox(height: 4),
                    Text(
                      'Optional: Extra guidance for AI-generated content.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _promptController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      decoration: _inputDecoration(
                        _generationMode == 'learn'
                            ? 'Ask for theory, architecture, patterns...'
                            : 'Ask for answer framing, follow-ups...',
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Submit Button ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isGenerating ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withAlpha(120),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        icon: isGenerating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(LucideIcons.sparkles, size: 18),
                        label: Text(
                          isGenerating ? 'Generating...' : 'Generate Course',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mode Toggle ─────────────────────────────────────────────────────────

  Widget _modeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          _modeOption('learn', LucideIcons.bookOpen, 'Learn'),
          _modeOption('interview_prep', LucideIcons.messageSquare, 'Interview Prep'),
        ],
      ),
    );
  }

  Widget _modeOption(String value, IconData icon, String label) {
    final isSelected = _generationMode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _generationMode = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textMedium,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _label(String text, {bool required = false}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          letterSpacing: 0,
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
              ]
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.spaceGrotesk(
        fontSize: 13,
        color: AppColors.textMedium,
      ),
      filled: true,
      fillColor: AppColors.bgLight,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderStroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderStroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderStroke),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: AppColors.textLight,
          ),
        ),
      ),
    );
  }
}
