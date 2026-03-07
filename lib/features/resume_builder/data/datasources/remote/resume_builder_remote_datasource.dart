import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/resume_builder/data/datasources/resume_builder_datasource.dart';
import 'package:kaarya/features/resume_builder/data/models/resume_builder_api_model.dart';

final resumeBuilderRemoteDatasourceProvider =
    Provider<IResumeBuilderRemoteDataSource>((ref) {
      return ResumeBuilderRemoteDataSource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class ResumeBuilderRemoteDataSource implements IResumeBuilderRemoteDataSource {
  final ApiClient _apiClient;

  ResumeBuilderRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<ResumeDraftApiModel> createDraft({
    required String title,
    required String template,
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? sections,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.resumeBuilder,
      data: {
        'title': title,
        'template': template,
        if (personalInfo != null && personalInfo.isNotEmpty)
          'personalInfo': personalInfo,
        if (sections != null && sections.isNotEmpty) 'sections': sections,
      },
    );
    final data = _extractDataMap(response);
    final draft = _asMap(data['draft']) ?? data;
    return ResumeDraftApiModel.fromApiResponse(draft);
  }

  @override
  Future<ResumeDraftsListApiResponse> listDrafts({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.resumeBuilderList,
      queryParameters: {'page': page, 'size': size},
    );
    final data = _extractDataMap(response);
    return ResumeDraftsListApiResponse.fromJson(data);
  }

  @override
  Future<ResumeDraftApiModel> getDraftById(String draftId) async {
    final response = await _apiClient.get(
      ApiEndpoints.resumeBuilderById(draftId),
    );
    final data = _extractDataMap(response);
    final draft = _asMap(data['draft']) ?? data;
    return ResumeDraftApiModel.fromApiResponse(draft);
  }

  @override
  Future<ResumeDraftApiModel> updateDraft({
    required String draftId,
    required Map<String, dynamic> fields,
  }) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.resumeBuilderById(draftId),
      data: fields,
    );
    final data = _extractDataMap(response);
    final draft = _asMap(data['draft']) ?? data;
    return ResumeDraftApiModel.fromApiResponse(draft);
  }

  @override
  Future<bool> deleteDraft(String draftId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.resumeBuilderById(draftId),
    );
    final body = response.data;
    if (body is Map) {
      final normalized = _castMap(body);
      return normalized['success'] == true;
    }
    return false;
  }

  @override
  Future<String> generatePdf(String draftId) async {
    final response = await _apiClient.post(
      ApiEndpoints.resumeBuilderGeneratePdf(draftId),
    );
    final data = _extractDataMap(response);
    return jsonString(data['pdfUrl'] ?? data['url']);
  }

  @override
  Future<bool> saveAsResume(String draftId) async {
    final response = await _apiClient.post(
      ApiEndpoints.resumeBuilderSave(draftId),
    );
    final body = response.data;
    if (body is Map) {
      final normalized = _castMap(body);
      return normalized['success'] == true;
    }
    return false;
  }

  @override
  Future<String> generateAiSummary({
    required List<String> skills,
    required List<String> experience,
    required String targetRole,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.resumeBuilderAiSummary,
      data: {
        'skills': skills,
        'experience': experience,
        'targetRole': targetRole,
      },
    );
    final data = _extractDataMap(response);
    return jsonString(data['summary']);
  }

  @override
  Future<List<String>> generateExperienceBullets({
    required String jobTitle,
    required String responsibilities,
    required List<String> techStack,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.resumeBuilderAiBullets,
      data: {
        'jobTitle': jobTitle,
        'responsibilities': responsibilities,
        'techStack': techStack,
      },
    );
    final data = _extractDataMap(response);
    return jsonStringList(data['bullets']);
  }

  @override
  Future<List<String>> generateAiSuggestions({
    required String step,
    required Map<String, dynamic> resumeData,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.resumeBuilderAiSuggestions,
      data: {'step': step, 'resumeData': resumeData},
    );
    final data = _extractDataMap(response);
    return jsonStringList(data['suggestions']);
  }

  @override
  Future<AtsScanResultApiModel> atsScan({
    required String filePath,
    String? targetRole,
    String? experienceLevel,
    String? jobDescription,
  }) async {
    final formData = FormData.fromMap({
      'resume': await MultipartFile.fromFile(filePath),
      if (targetRole != null && targetRole.isNotEmpty) 'targetRole': targetRole,
      if (experienceLevel != null && experienceLevel.isNotEmpty)
        'experienceLevel': experienceLevel,
      if (jobDescription != null && jobDescription.isNotEmpty)
        'jobDescription': jobDescription,
    });

    final response = await _apiClient.uploadFile(
      ApiEndpoints.resumeBuilderAtsScan,
      formData: formData,
    );
    final data = _extractDataMap(response);
    final result = _asMap(data['result']) ?? data;
    return AtsScanResultApiModel.fromApiResponse(result);
  }

  Map<String, dynamic> _extractDataMap(Response response) {
    final body = response.data;
    if (body is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid response payload.',
      );
    }

    final normalized = _castMap(body);
    if (normalized['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: _nullableString(normalized['message']) ?? 'Request failed.',
      );
    }

    final data = normalized['data'];
    if (data is Map) {
      return _castMap(data);
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _castMap(Map value) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return _castMap(value);
    return null;
  }

  String? _nullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }
}
