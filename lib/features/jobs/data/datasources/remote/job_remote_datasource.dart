import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/features/jobs/data/datasources/job_datasource.dart';
import 'package:kaarya/features/jobs/data/models/job_api_models.dart';

final jobRemoteDatasourceProvider = Provider<IJobRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return JobRemoteDatasource(apiClient: apiClient);
});

Map<String, dynamic> _castMap(Map v) =>
    v.map((k, v2) => MapEntry(k.toString(), v2));
Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return _castMap(v);
  return null;
}

class JobRemoteDatasource implements IJobRemoteDataSource {
  final ApiClient _apiClient;

  JobRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  Map<String, dynamic> _extractDataMap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return _castMap(data['data'] as Map);
    }
    if (data is Map) return _castMap(data);
    return const {};
  }

  Future<List<JobApiModel>> _fetchJobs({
    required String feed,
    bool remoteOnly = false,
    String? searchQuery,
    String? locationQuery,
    String? status,
    String? employmentType,
    String? engagementType,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.jobs,
      queryParameters: {
        'page': 1,
        'size': 30,
        'feed': feed,
        if (remoteOnly) 'remoteOnly': true,
        if ((searchQuery ?? '').trim().isNotEmpty)
          'search': searchQuery!.trim(),
        if ((locationQuery ?? '').trim().isNotEmpty)
          'location': locationQuery!.trim(),
        if ((status ?? '').trim().isNotEmpty) 'status': status!.trim(),
        if ((employmentType ?? '').trim().isNotEmpty)
          'employmentType': employmentType!.trim(),
        if ((engagementType ?? '').trim().isNotEmpty)
          'engagementType': engagementType!.trim(),
      },
    );

    final data = _extractDataMap(response);
    return JobApiModel.fromApiList(data['jobs']);
  }

  List<JobApiModel> _buildUrgentJobs(List<JobApiModel> forYou) {
    const urgentStatuses = ['shortlisted', 'interview_scheduled'];
    return forYou
        .where((j) => urgentStatuses.contains(j.status.toLowerCase()))
        .toList();
  }

  @override
  Future<JobsSectionApiModel> getJobsSection({
    String? searchQuery,
    String? locationQuery,
    String? status,
    String? employmentType,
    String? engagementType,
  }) async {
    final s = searchQuery?.trim() ?? '';
    final l = locationQuery?.trim() ?? '';
    final st = status?.trim() ?? '';
    final et = employmentType?.trim() ?? '';
    final egt = engagementType?.trim() ?? '';

    final results = await Future.wait([
      _fetchJobs(
        feed: 'for_you',
        searchQuery: s,
        locationQuery: l,
        status: st,
        employmentType: et,
        engagementType: egt,
      ),
      _fetchJobs(
        feed: 'trending',
        searchQuery: s,
        locationQuery: l,
        status: st,
        employmentType: et,
        engagementType: egt,
      ),
      _fetchJobs(
        feed: 'last_week',
        searchQuery: s,
        locationQuery: l,
        status: st,
        employmentType: et,
        engagementType: egt,
      ),
      _fetchJobs(
        feed: 'for_you',
        remoteOnly: true,
        searchQuery: s,
        locationQuery: l,
        status: st,
        employmentType: et,
        engagementType: egt,
      ),
    ]);

    final forYou = results[0];
    final trending = results[1];
    final newThisWeek = results[2];
    final remote = results[3];

    return JobsSectionApiModel(
      searchQuery: s,
      locationQuery: l,
      jobs: JobsBucketApiModel(
        forYou: forYou,
        trending: trending,
        newThisWeek: newThisWeek,
        remote: remote,
        urgent: _buildUrgentJobs(forYou),
      ),
    );
  }

  @override
  Future<JobDetailApiModel> getJobDetail(String jobId) async {
    final response = await _apiClient.get(ApiEndpoints.jobById(jobId));
    final data = _extractDataMap(response);
    final job = _asMap(data['job']) ?? data;
    return JobDetailApiModel.fromApiResponse(job);
  }

  @override
  Future<void> recordJobView(String jobId) async {
    await _apiClient.post(ApiEndpoints.jobView(jobId));
  }

  @override
  Future<JobApiModel> createJob(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiEndpoints.jobs, data: data);
    final responseData = _extractDataMap(response);
    final job = _asMap(responseData['job']) ?? responseData;
    return JobApiModel.fromApiResponse(job);
  }

  @override
  Future<JobApiModel> updateJob(String jobId, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      ApiEndpoints.jobById(jobId),
      data: data,
    );
    final responseData = _extractDataMap(response);
    final job = _asMap(responseData['job']) ?? responseData;
    return JobApiModel.fromApiResponse(job);
  }

  @override
  Future<bool> deleteJob(String jobId) async {
    final response = await _apiClient.delete(ApiEndpoints.jobById(jobId));
    final body = response.data;
    if (body is Map) {
      return _castMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<JobMetricsApiModel> getJobMetrics(String jobId) async {
    final response = await _apiClient.get(ApiEndpoints.jobMetrics(jobId));
    final data = _extractDataMap(response);
    return JobMetricsApiModel.fromJson(data);
  }

  @override
  Future<bool> applyToJob(
    String jobId, {
    String? resumeId,
    String? coverLetter,
    List<String>? portfolioLinks,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.applyToJob(jobId),
      data: {
        if (resumeId != null) 'resumeId': resumeId,
        if (coverLetter != null && coverLetter.isNotEmpty)
          'coverLetter': coverLetter,
        if (portfolioLinks != null && portfolioLinks.isNotEmpty)
          'portfolioLinks': portfolioLinks,
      },
    );
    final body = response.data;
    if (body is Map) {
      return _castMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<List<JobApiModel>> listCompanyJobs({
    required String companyId,
    String? status,
    String? search,
    int page = 1,
    int size = 50,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.jobs,
      queryParameters: {
        'companyId': companyId,
        'page': page,
        'size': size,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = _extractDataMap(response);
    return JobApiModel.fromApiList(data['jobs'] ?? data['data'] ?? data);
  }

  @override
  Future<List<JobApiModel>> listCollegeJobs({
    required String collegeId,
    String? status,
    String? search,
    int page = 1,
    int size = 50,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.jobs,
      queryParameters: {
        'collegeId': collegeId,
        'page': page,
        'size': size,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = _extractDataMap(response);
    return JobApiModel.fromApiList(data['jobs'] ?? data['data'] ?? data);
  }

  bool _isBookmarkSuccess(Response response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) return false;
    final body = response.data;
    if (body == null) return true;
    if (body is! Map) return true;
    final map = _castMap(body);
    if (map['success'] == false) return false;
    if (map['success'] == true) return true;
    final data = map['data'];
    if (data is Map) {
      final dataMap = _castMap(data);
      if (dataMap['success'] == false) return false;
      if (dataMap['success'] == true) return true;
    }
    return true;
  }

  @override
  Future<bool> toggleJobBookmark(String jobId, bool save) async {
    final endpoint = ApiEndpoints.bookmarkJob(jobId);
    final response = save
        ? await _apiClient.post(endpoint)
        : await _apiClient.delete(endpoint);
    return _isBookmarkSuccess(response);
  }
}
