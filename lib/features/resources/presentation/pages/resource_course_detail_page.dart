import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';
import 'package:kaarya/features/resources/presentation/state/resource_state.dart';
import 'package:kaarya/features/resources/presentation/view_model/resource_view_model.dart';

class ResourceCourseDetailPage extends ConsumerStatefulWidget {
  final String courseId;

  const ResourceCourseDetailPage({super.key, required this.courseId});

  @override
  ConsumerState<ResourceCourseDetailPage> createState() =>
      _ResourceCourseDetailPageState();
}

class _ResourceCourseDetailPageState
    extends ConsumerState<ResourceCourseDetailPage> {
  final Set<int> _completedChapters = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(resourceViewModelProvider.notifier).loadCourseDetail(widget.courseId);
    });
  }

  void _toggleChapter(int index) {
    setState(() {
      if (_completedChapters.contains(index)) {
        _completedChapters.remove(index);
      } else {
        _completedChapters.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourceViewModelProvider);
    final isLoading = state.courseDetailStatus == ResourceLoadStatus.loading;
    final isError = state.courseDetailStatus == ResourceLoadStatus.error;
    final course = state.courseDetailData;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => AppRoutes.pop(context),
        ),
      ),
      body: Builder(
        builder: (ctx) {
          if (isLoading) {
            return const Center(child: LoaderWidget());
          }
          if (isError || course == null) {
            return _buildError(state.courseDetailErrorMessage);
          }
          return _buildContent(course);
        },
      ),
    );
  }

  // ─── Full content ────────────────────────────────────────────────────────

  Widget _buildContent(ResourceCourseEntity course) {
    final completedCount = _completedChapters.length;
    final totalChapters = course.chapters.length;
    final progress = totalChapters > 0 ? completedCount / totalChapters : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        // ── Title section ───────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _badge(
                  course.generationMode == 'interview_prep' ? 'Interview Prep' : 'Learn',
                  icon: course.generationMode == 'interview_prep'
                      ? LucideIcons.messageSquare
                      : LucideIcons.bookOpen,
                ),
                _badge(_capitalize(course.difficulty)),
                _badge(
                  course.visibility == 'public' ? 'Public' : 'Private',
                  icon: course.visibility == 'public' ? LucideIcons.globe : LucideIcons.lock,
                ),
                ...course.targetRoles.take(2).map((r) => _badge(r, small: true)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Progress Bar ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderStroke2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Course Progress',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  Text(
                    '$completedCount / $totalChapters chapters',
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.bgLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success2),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).round()}% complete',
                style: const TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Description ─────────────────────────────────────────────────────
        if (course.description.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderStroke2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Chapters ────────────────────────────────────────────────────────
        const Text(
          'Learning Path',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: 10),
        ...course.chapters.asMap().entries.map((entry) => _buildChapterTile(entry.key, entry.value)),
      ],
    );
  }

  // ─── Chapter Tile ───────────────────────────────────────────────────────

  Widget _buildChapterTile(int index, CourseChapterEntity chapter) {
    final isCompleted = _completedChapters.contains(index);
    final hasContent = chapter.sections.isNotEmpty ||
        chapter.coreConcepts.isNotEmpty ||
        chapter.interviewQuestions.isNotEmpty ||
        chapter.practicePrompts.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStroke2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chapter ${index + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                chapter.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: isCompleted
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.check, size: 11, color: AppColors.success2),
                      SizedBox(width: 3),
                      Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: AppColors.textLight,
                ),
          children: hasContent
              ? [_buildChapterContent(index, chapter, isCompleted)]
              : [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'No content available.',
                      style: TextStyle(fontSize: 13, color: AppColors.textLight),
                    ),
                  )
                ],
        ),
      ),
    );
  }

  Widget _buildChapterContent(
    int index,
    CourseChapterEntity chapter,
    bool isCompleted,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBFDFF),
        border: Border(top: BorderSide(color: AppColors.borderStroke2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Complete button ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _toggleChapter(index),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 32),
                    side: BorderSide(
                      color: isCompleted ? AppColors.success2 : AppColors.borderStroke,
                    ),
                    foregroundColor: isCompleted ? AppColors.success2 : AppColors.textLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: Icon(
                    isCompleted ? LucideIcons.check : LucideIcons.check,
                    size: 13,
                  ),
                  label: Text(
                    isCompleted ? 'Completed' : 'Mark Done',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reading Material
                if (chapter.sections.isNotEmpty) ...[
                  _sectionHeader('READING MATERIAL', LucideIcons.fileText),
                  ...chapter.sections.map((s) => _buildSection(s)),
                ],

                // Core Concepts
                if (chapter.coreConcepts.isNotEmpty) ...[
                  if (chapter.sections.isNotEmpty) const SizedBox(height: 12),
                  _sectionHeader('CORE CONCEPTS', LucideIcons.brain),
                  ...chapter.coreConcepts.map((c) => _buildCoreConcept(c)),
                ],

                // Interview Q&A
                if (chapter.interviewQuestions.isNotEmpty) ...[
                  if (chapter.sections.isNotEmpty || chapter.coreConcepts.isNotEmpty)
                    const SizedBox(height: 12),
                  _sectionHeader('INTERVIEW Q&A', LucideIcons.messageSquare),
                  ...chapter.interviewQuestions.map((q) => _buildQA(q)),
                ],

                // Practice Prompts
                if (chapter.practicePrompts.isNotEmpty) ...[
                  if (chapter.sections.isNotEmpty ||
                      chapter.coreConcepts.isNotEmpty ||
                      chapter.interviewQuestions.isNotEmpty)
                    const SizedBox(height: 12),
                  _sectionHeader('PRACTICE PROMPTS', LucideIcons.zap),
                  ...chapter.practicePrompts.asMap().entries.map(
                        (e) => _buildPromptItem(e.key + 1, e.value),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textMedium),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ChapterSectionEntity section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
          if (section.subheadings.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...section.subheadings.map((sub) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: CircleAvatar(radius: 2.5, backgroundColor: AppColors.textLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sub,
                      style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildCoreConcept(CoreConceptEntity concept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderStroke2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  concept.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          if (concept.explanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              concept.explanation,
              style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQA(InterviewQuestionEntity qa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderStroke2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q. ${qa.question}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          if (qa.sampleAnswer.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFD0E8FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SAMPLE ANSWER',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    qa.sampleAnswer,
                    style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromptItem(int number, String prompt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              prompt,
              style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  Widget _badge(String text, {IconData? icon, bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: AppColors.textLight),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: small ? 11 : 12,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleAlert, size: 48, color: AppColors.error.withAlpha(160)),
            const SizedBox(height: 12),
            Text(
              message ?? 'Failed to load course',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(resourceViewModelProvider.notifier)
                  .loadCourseDetail(widget.courseId),
              icon: const Icon(LucideIcons.rotateCcw, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
