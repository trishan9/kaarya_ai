import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/resume_builder/domain/entities/ats_scan_result_entity.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/ats_scan_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/create_draft_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/delete_draft_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/generate_ai_suggestions_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/generate_ai_summary_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/generate_experience_bullets_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/generate_pdf_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/get_draft_by_id_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/list_drafts_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/save_as_resume_usecase.dart';
import 'package:kaarya/features/resume_builder/domain/usecases/update_draft_usecase.dart';
import 'package:kaarya/features/resume_builder/presentation/state/resume_builder_state.dart';

final resumeBuilderViewModelProvider =
    NotifierProvider<ResumeBuilderViewModel, ResumeBuilderState>(
      ResumeBuilderViewModel.new,
    );

class ResumeBuilderViewModel extends Notifier<ResumeBuilderState> {
  late final CreateDraftUseCase _createDraftUseCase;
  late final ListDraftsUseCase _listDraftsUseCase;
  late final GetDraftByIdUseCase _getDraftByIdUseCase;
  late final UpdateDraftUseCase _updateDraftUseCase;
  late final DeleteDraftUseCase _deleteDraftUseCase;
  late final GeneratePdfUseCase _generatePdfUseCase;
  late final SaveAsResumeUseCase _saveAsResumeUseCase;
  late final GenerateAiSummaryUseCase _generateAiSummaryUseCase;
  late final GenerateExperienceBulletsUseCase _generateExperienceBulletsUseCase;
  late final GenerateAiSuggestionsUseCase _generateAiSuggestionsUseCase;
  late final AtsScanUseCase _atsScanUseCase;

  @override
  ResumeBuilderState build() {
    _createDraftUseCase = ref.read(createDraftUseCaseProvider);
    _listDraftsUseCase = ref.read(listDraftsUseCaseProvider);
    _getDraftByIdUseCase = ref.read(getDraftByIdUseCaseProvider);
    _updateDraftUseCase = ref.read(updateDraftUseCaseProvider);
    _deleteDraftUseCase = ref.read(deleteDraftUseCaseProvider);
    _generatePdfUseCase = ref.read(generatePdfUseCaseProvider);
    _saveAsResumeUseCase = ref.read(saveAsResumeUseCaseProvider);
    _generateAiSummaryUseCase = ref.read(generateAiSummaryUseCaseProvider);
    _generateExperienceBulletsUseCase = ref.read(
      generateExperienceBulletsUseCaseProvider,
    );
    _generateAiSuggestionsUseCase = ref.read(
      generateAiSuggestionsUseCaseProvider,
    );
    _atsScanUseCase = ref.read(atsScanUseCaseProvider);
    return const ResumeBuilderState();
  }

  void resetState() {
    state = const ResumeBuilderState();
  }

  Future<void> loadDrafts({int? page, bool forceRefresh = false}) async {
    final nextPage = page ?? state.currentPage;

    if (!forceRefresh &&
        nextPage == state.currentPage &&
        state.draftsListStatus == ResumeBuilderLoadStatus.loaded &&
        state.draftsListData != null) {
      return;
    }

    state = state.copyWith(
      draftsListStatus: ResumeBuilderLoadStatus.loading,
      draftsListErrorMessage: null,
      currentPage: nextPage,
    );

    final result = await _listDraftsUseCase(
      ListDraftsUseCaseParams(page: nextPage, size: state.pageSize),
    );

    result.fold(
      (failure) => state = state.copyWith(
        draftsListStatus: ResumeBuilderLoadStatus.error,
        draftsListErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        draftsListStatus: ResumeBuilderLoadStatus.loaded,
        draftsListData: data,
        draftsListErrorMessage: null,
      ),
    );
  }

  Future<void> loadDraftDetail(String draftId) async {
    state = state.copyWith(
      draftDetailStatus: ResumeBuilderLoadStatus.loading,
      draftDetailData: null,
      draftDetailErrorMessage: null,
    );

    final result = await _getDraftByIdUseCase(
      GetDraftByIdUseCaseParams(draftId: draftId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        draftDetailStatus: ResumeBuilderLoadStatus.error,
        draftDetailErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        draftDetailStatus: ResumeBuilderLoadStatus.loaded,
        draftDetailData: data,
        draftDetailErrorMessage: null,
      ),
    );
  }

  Future<Failure?> createDraft({
    required String title,
    required String template,
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? sections,
  }) async {
    state = state.copyWith(
      createDraftStatus: ResumeBuilderLoadStatus.loading,
      createDraftErrorMessage: null,
    );

    final result = await _createDraftUseCase(
      CreateDraftUseCaseParams(
        title: title,
        template: template,
        personalInfo: personalInfo,
        sections: sections,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          createDraftStatus: ResumeBuilderLoadStatus.error,
          createDraftErrorMessage: failure.message,
        );
        return failure;
      },
      (data) {
        state = state.copyWith(
          createDraftStatus: ResumeBuilderLoadStatus.loaded,
          draftDetailData: data,
          createDraftErrorMessage: null,
        );
        return null;
      },
    );
  }

  Future<Failure?> updateDraft({
    required String draftId,
    required Map<String, dynamic> fields,
  }) async {
    state = state.copyWith(
      updateDraftStatus: ResumeBuilderLoadStatus.loading,
      updateDraftErrorMessage: null,
    );

    final result = await _updateDraftUseCase(
      UpdateDraftUseCaseParams(draftId: draftId, fields: fields),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          updateDraftStatus: ResumeBuilderLoadStatus.error,
          updateDraftErrorMessage: failure.message,
        );
        return failure;
      },
      (data) {
        state = state.copyWith(
          updateDraftStatus: ResumeBuilderLoadStatus.loaded,
          draftDetailData: data,
          updateDraftErrorMessage: null,
        );
        return null;
      },
    );
  }

  Future<Failure?> deleteDraft(String draftId) async {
    state = state.copyWith(
      deleteDraftStatus: ResumeBuilderLoadStatus.loading,
      deleteDraftErrorMessage: null,
    );

    final result = await _deleteDraftUseCase(
      DeleteDraftUseCaseParams(draftId: draftId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          deleteDraftStatus: ResumeBuilderLoadStatus.error,
          deleteDraftErrorMessage: failure.message,
        );
        return failure;
      },
      (_) {
        state = state.copyWith(
          deleteDraftStatus: ResumeBuilderLoadStatus.loaded,
          deleteDraftErrorMessage: null,
        );
        return null;
      },
    );
  }

  Future<(GeneratePdfResultEntity?, Failure?)> generatePdf(
    String draftId,
  ) async {
    state = state.copyWith(
      generatePdfStatus: ResumeBuilderLoadStatus.loading,
      generatePdfErrorMessage: null,
    );

    final result = await _generatePdfUseCase(
      GeneratePdfUseCaseParams(draftId: draftId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          generatePdfStatus: ResumeBuilderLoadStatus.error,
          generatePdfErrorMessage: failure.message,
        );
        return (null, failure);
      },
      (data) {
        state = state.copyWith(
          generatePdfStatus: ResumeBuilderLoadStatus.loaded,
          generatePdfData: data,
          generatePdfErrorMessage: null,
        );
        return (data, null);
      },
    );
  }

  Future<Failure?> saveAsResume(String draftId) async {
    state = state.copyWith(
      saveResumeStatus: ResumeBuilderLoadStatus.loading,
      saveResumeErrorMessage: null,
    );

    final result = await _saveAsResumeUseCase(
      SaveAsResumeUseCaseParams(draftId: draftId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          saveResumeStatus: ResumeBuilderLoadStatus.error,
          saveResumeErrorMessage: failure.message,
        );
        return failure;
      },
      (_) {
        state = state.copyWith(
          saveResumeStatus: ResumeBuilderLoadStatus.loaded,
          saveResumeErrorMessage: null,
        );
        return null;
      },
    );
  }

  Future<(AiSummaryResultEntity?, Failure?)> generateAiSummary({
    required List<String> skills,
    required List<String> experience,
    required String targetRole,
  }) async {
    state = state.copyWith(
      aiSummaryStatus: ResumeBuilderLoadStatus.loading,
      aiSummaryErrorMessage: null,
    );

    final result = await _generateAiSummaryUseCase(
      GenerateAiSummaryUseCaseParams(
        skills: skills,
        experience: experience,
        targetRole: targetRole,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          aiSummaryStatus: ResumeBuilderLoadStatus.error,
          aiSummaryErrorMessage: failure.message,
        );
        return (null, failure);
      },
      (data) {
        state = state.copyWith(
          aiSummaryStatus: ResumeBuilderLoadStatus.loaded,
          aiSummaryData: data,
          aiSummaryErrorMessage: null,
        );
        return (data, null);
      },
    );
  }

  Future<(ExperienceBulletsResultEntity?, Failure?)> generateExperienceBullets({
    required String jobTitle,
    required String responsibilities,
    required List<String> techStack,
  }) async {
    state = state.copyWith(
      experienceBulletsStatus: ResumeBuilderLoadStatus.loading,
      experienceBulletsErrorMessage: null,
    );

    final result = await _generateExperienceBulletsUseCase(
      GenerateExperienceBulletsUseCaseParams(
        jobTitle: jobTitle,
        responsibilities: responsibilities,
        techStack: techStack,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          experienceBulletsStatus: ResumeBuilderLoadStatus.error,
          experienceBulletsErrorMessage: failure.message,
        );
        return (null, failure);
      },
      (data) {
        state = state.copyWith(
          experienceBulletsStatus: ResumeBuilderLoadStatus.loaded,
          experienceBulletsData: data,
          experienceBulletsErrorMessage: null,
        );
        return (data, null);
      },
    );
  }

  Future<(AiSuggestionsResultEntity?, Failure?)> generateAiSuggestions({
    required String step,
    required Map<String, dynamic> resumeData,
  }) async {
    state = state.copyWith(
      aiSuggestionsStatus: ResumeBuilderLoadStatus.loading,
      aiSuggestionsErrorMessage: null,
    );

    final result = await _generateAiSuggestionsUseCase(
      GenerateAiSuggestionsUseCaseParams(step: step, resumeData: resumeData),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          aiSuggestionsStatus: ResumeBuilderLoadStatus.error,
          aiSuggestionsErrorMessage: failure.message,
        );
        return (null, failure);
      },
      (data) {
        state = state.copyWith(
          aiSuggestionsStatus: ResumeBuilderLoadStatus.loaded,
          aiSuggestionsData: data,
          aiSuggestionsErrorMessage: null,
        );
        return (data, null);
      },
    );
  }

  Future<(AtsScanResultEntity?, Failure?)> atsScan({
    required String filePath,
    String? targetRole,
    String? experienceLevel,
    String? jobDescription,
  }) async {
    state = state.copyWith(
      atsScanStatus: ResumeBuilderLoadStatus.loading,
      atsScanErrorMessage: null,
    );

    final result = await _atsScanUseCase(
      AtsScanUseCaseParams(
        filePath: filePath,
        targetRole: targetRole,
        experienceLevel: experienceLevel,
        jobDescription: jobDescription,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          atsScanStatus: ResumeBuilderLoadStatus.error,
          atsScanErrorMessage: failure.message,
        );
        return (null, failure);
      },
      (data) {
        state = state.copyWith(
          atsScanStatus: ResumeBuilderLoadStatus.loaded,
          atsScanData: data,
          atsScanErrorMessage: null,
        );
        return (data, null);
      },
    );
  }
}
