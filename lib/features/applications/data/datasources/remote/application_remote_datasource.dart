import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';

import 'package:kaarya/features/applications/data/datasources/application_datasource.dart';
import 'package:kaarya/features/applications/data/models/application_api_model.dart';

final applicationRemoteDatasourceProvider =
    Provider<IApplicationRemoteDataSource>((ref) {
      return ApplicationRemoteDataSource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class ApplicationRemoteDataSource implements IApplicationRemoteDataSource {
  final ApiClient _apiClient;

  ApplicationRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Map<String, dynamic> _extractData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    if (body is Map<String, dynamic>) return body;
    return const <String, dynamic>{};
  }

  dynamic _extractRawData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) return body['data'];
    return body;
  }

  @override
  Future<List<ApplicationApiModel>> getMyApplications({
    int page = 1,
    int size = 50,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiEndpoints.myApplications,
      queryParameters: queryParams,
    );

    final data = _extractRawData(response);
    if (data is Map<String, dynamic>) {
      final list = data['applications'] ?? data['data'] ?? data['items'] ?? data['rows'];
      if (list is List) {
        return ApplicationApiModel.fromApiList(list);
      }
    }

    if (data is List) {
      return ApplicationApiModel.fromApiList(data);
    }

    return const <ApplicationApiModel>[];
  }

  @override
  Future<ApplicationSummaryApiModel> getApplicationsSummary({
    String? month,
    String? statuses,
  }) async {
    final queryParams = <String, dynamic>{};
    if (month != null && month.isNotEmpty) queryParams['month'] = month;
    if (statuses != null && statuses.isNotEmpty) {
      queryParams['statuses'] = statuses;
    }

    final response = await _apiClient.get(
      ApiEndpoints.myApplicationsSummary,
      queryParameters: queryParams,
    );

    final data = _extractData(response);
    return ApplicationSummaryApiModel.fromJson(data);
  }

  @override
  Future<ApplicationApiModel> getApplicationForJob({
    required String jobId,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.myApplicationByJob(jobId),
    );

    final data = _extractData(response);
    return ApplicationApiModel.fromJson(data);
  }

  @override
  Future<bool> applyToJob(
    String jobId, {
    String? resumeId,
    String? resumeFilePath,
    List<int>? resumeBytes,
    String? resumeFilename,
    String? coverLetter,
    List<String>? portfolioLinks,
  }) async {
    final formFields = <String, dynamic>{};
    if (resumeId != null && resumeId.isNotEmpty) {
      formFields['resumeId'] = resumeId;
    }
    if (resumeFilePath != null && resumeFilePath.isNotEmpty) {
      formFields['resume'] = await MultipartFile.fromFile(
        resumeFilePath,
        filename: resumeFilePath.split(RegExp(r'[/\\]')).last,
      );
    } else if (resumeBytes != null &&
        resumeBytes.isNotEmpty &&
        resumeFilename != null &&
        resumeFilename.isNotEmpty) {
      formFields['resume'] = MultipartFile.fromBytes(
        resumeBytes,
        filename: resumeFilename,
      );
    }
    if (coverLetter != null && coverLetter.isNotEmpty) {
      formFields['coverLetter'] = coverLetter;
    }
    if (portfolioLinks != null && portfolioLinks.isNotEmpty) {
      formFields['portfolioLinks'] = portfolioLinks;
    }

    final formData = FormData.fromMap(formFields);

    await _apiClient.uploadFile(
      ApiEndpoints.applyToJob(jobId),
      formData: formData,
    );

    return true;
  }

  @override
  Future<List<ApplicationApiModel>> getJobApplications({
    required String jobId,
    int page = 1,
    int size = 50,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiEndpoints.jobApplications(jobId),
      queryParameters: queryParams,
    );

    final data = _extractRawData(response);
    if (data is Map<String, dynamic>) {
      final innerData = data['data'];
      if (innerData is List) {
        return ApplicationApiModel.fromApiList(innerData);
      }
    }
    if (data is List) {
      return ApplicationApiModel.fromApiList(data);
    }

    return const <ApplicationApiModel>[];
  }

  @override
  Future<List<JobApplicantApiModel>> getJobApplicants({
    required String jobId,
    int page = 1,
    int size = 50,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiEndpoints.jobApplications(jobId),
      queryParameters: queryParams,
    );

    final data = _extractRawData(response);
    List<dynamic>? list;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      list = inner is List ? inner : (data['applications'] is List ? data['applications'] : null);
    } else if (data is List) {
      list = data;
    }

    return JobApplicantApiModel.fromApiList(list ?? []);
  }

  @override
  Future<bool> updateApplication({
    required String jobId,
    required String applicationId,
    String? status,
    DateTime? interviewScheduledAt,
    String? interviewNote,
  }) async {
    final body = <String, dynamic>{};
    if (status != null && status.isNotEmpty) body['status'] = status;
    if (interviewScheduledAt != null) {
      body['interviewScheduledAt'] = interviewScheduledAt.toIso8601String();
    }
    if (interviewNote != null) body['interviewNote'] = interviewNote;
    if (body.isEmpty) throw ArgumentError('At least one field is required');

    await _apiClient.patch(
      ApiEndpoints.updateApplication(jobId, applicationId),
      data: body,
    );

    return true;
  }

  @override
  Future<List<ResumeApiModel>> listMyResumes({
    int page = 1,
    int size = 50,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.myResumes,
      queryParameters: {'page': page, 'size': size},
    );

    final data = _extractRawData(response);
    if (data is Map<String, dynamic>) {
      final innerData = data['data'];
      if (innerData is List) {
        return ResumeApiModel.fromApiList(innerData);
      }
    }
    if (data is List) {
      return ResumeApiModel.fromApiList(data);
    }

    return const <ResumeApiModel>[];
  }

  @override
  Future<ResumeApiModel> uploadResume({required String filePath}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final response = await _apiClient.uploadFile(
      ApiEndpoints.myResumes,
      formData: formData,
    );

    final data = _extractData(response);
    return ResumeApiModel.fromJson(data);
  }

  @override
  Future<bool> deleteResume({required String resumeId}) async {
    await _apiClient.delete(ApiEndpoints.deleteResume(resumeId));
    return true;
  }

  @override
  Future<bool> updateResumeActivity({
    required String jobId,
    required String applicationId,
    required String action,
  }) async {
    // Backend expects PATCH with "viewed" or "downloaded" (matches web frontend)
    await _apiClient.patch(
      ApiEndpoints.updateResumeActivity(jobId, applicationId),
      data: {'action': action},
    );
    return true;
  }
}
