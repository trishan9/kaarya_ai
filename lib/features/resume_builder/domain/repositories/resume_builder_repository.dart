import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/resume_builder/domain/entities/ats_scan_result_entity.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';

abstract interface class IResumeBuilderRepository {
  Future<Either<Failure, ResumeDraftEntity>> createDraft({
    required String title,
    required String template,
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? sections,
  });

  Future<Either<Failure, ResumeDraftsListEntity>> listDrafts({
    int page,
    int size,
  });

  Future<Either<Failure, ResumeDraftEntity>> getDraftById(String draftId);

  Future<Either<Failure, ResumeDraftEntity>> updateDraft({
    required String draftId,
    required Map<String, dynamic> fields,
  });

  Future<Either<Failure, bool>> deleteDraft(String draftId);

  Future<Either<Failure, GeneratePdfResultEntity>> generatePdf(String draftId);

  Future<Either<Failure, bool>> saveAsResume(String draftId);

  Future<Either<Failure, AiSummaryResultEntity>> generateAiSummary({
    required List<String> skills,
    required List<String> experience,
    required String targetRole,
  });

  Future<Either<Failure, ExperienceBulletsResultEntity>>
  generateExperienceBullets({
    required String jobTitle,
    required String responsibilities,
    required List<String> techStack,
  });

  Future<Either<Failure, AiSuggestionsResultEntity>> generateAiSuggestions({
    required String step,
    required Map<String, dynamic> resumeData,
  });

  Future<Either<Failure, AtsScanResultEntity>> atsScan({
    required String filePath,
    String? targetRole,
    String? experienceLevel,
    String? jobDescription,
  });
}
