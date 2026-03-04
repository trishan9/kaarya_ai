import 'package:kaarya/features/resume_builder/data/models/resume_builder_api_model.dart';
import 'package:kaarya/features/resume_builder/data/models/resume_draft_hive_model.dart';

abstract interface class IResumeBuilderRemoteDataSource {
  Future<ResumeDraftApiModel> createDraft({
    required String title,
    required String template,
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? sections,
  });

  Future<ResumeDraftsListApiResponse> listDrafts({int page, int size});

  Future<ResumeDraftApiModel> getDraftById(String draftId);

  Future<ResumeDraftApiModel> updateDraft({
    required String draftId,
    required Map<String, dynamic> fields,
  });

  Future<bool> deleteDraft(String draftId);

  Future<String> generatePdf(String draftId);

  Future<bool> saveAsResume(String draftId);

  Future<String> generateAiSummary({
    required List<String> skills,
    required List<String> experience,
    required String targetRole,
  });

  Future<List<String>> generateExperienceBullets({
    required String jobTitle,
    required String responsibilities,
    required List<String> techStack,
  });

  Future<List<String>> generateAiSuggestions({
    required String step,
    required Map<String, dynamic> resumeData,
  });

  Future<AtsScanResultApiModel> atsScan({
    required String filePath,
    String? targetRole,
    String? experienceLevel,
    String? jobDescription,
  });
}

abstract interface class IResumeBuilderLocalDataSource {
  Future<void> saveDraftsList(List<ResumeDraftHiveModel> data);
  Future<List<ResumeDraftHiveModel>> listDrafts();

  Future<void> saveDraft(ResumeDraftHiveModel data);
  Future<ResumeDraftHiveModel?> getDraftById(String draftId);

  Future<void> deleteDraft(String draftId);
}

class ResumeDraftsListApiResponse {
  final List<ResumeDraftApiModel> drafts;
  final int totalCount;
  final int page;
  final int size;

  const ResumeDraftsListApiResponse({
    required this.drafts,
    required this.totalCount,
    required this.page,
    required this.size,
  });

  factory ResumeDraftsListApiResponse.fromJson(Map<String, dynamic> json) {
    return ResumeDraftsListApiResponse(
      drafts: ResumeDraftApiModel.fromApiList(json['drafts']),
      totalCount: json['totalCount'] is int ? json['totalCount'] as int : 0,
      page: json['page'] is int ? json['page'] as int : 1,
      size: json['size'] is int ? json['size'] as int : 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drafts': drafts.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'size': size,
    };
  }
}
