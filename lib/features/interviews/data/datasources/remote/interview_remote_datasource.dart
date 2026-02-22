import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/features/interviews/data/datasources/interview_datasource.dart';
import 'package:kaarya/features/interviews/data/models/interview_api_model.dart';

final interviewRemoteDatasourceProvider = Provider<IInterviewRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return InterviewRemoteDatasource(apiClient: apiClient);
});

Map<String, dynamic> _castMap(Map v) =>
    v.map((k, v2) => MapEntry(k.toString(), v2));

Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return _castMap(v);
  return null;
}

class InterviewRemoteDatasource implements IInterviewRemoteDataSource {
  final ApiClient _apiClient;

  InterviewRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

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

  String? _nullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  Future<List<InterviewApiModel>> _fetchInterviews({
    required String ownership,
    String sortBy = 'updated',
    String? searchQuery,
    String? status,
    String? interviewType,
    bool discover = true,
    bool allowForbidden = false,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.interviews,
        queryParameters: {
          'page': 1,
          'size': 50,
          'ownership': ownership,
          'sortBy': sortBy,
          if ((searchQuery ?? '').trim().isNotEmpty)
            'search': searchQuery!.trim(),
          if ((status ?? '').trim().isNotEmpty) 'status': status!.trim(),
          if ((interviewType ?? '').trim().isNotEmpty)
            'interviewType': interviewType!.trim(),
          'discover': discover,
        },
      );

      final data = _extractDataMap(response);
      return InterviewApiModel.fromApiList(data['interviews']);
    } on DioException catch (e) {
      if (allowForbidden && e.response?.statusCode == 403) {
        return const <InterviewApiModel>[];
      }
      rethrow;
    }
  }

  String _ownershipForAttemptFilter(String value) {
    switch (value) {
      case 'attempted':
        return 'taken_by_me';
      case 'not_attempted':
        return 'not_taken';
      default:
        return 'all';
    }
  }

  String? _normalizeInterviewSort(String? sortBy) {
    final normalized = (sortBy ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'newest':
      case 'popular':
      case 'updated':
      case 'title':
        return normalized;
      default:
        return null;
    }
  }

  double _calculateAverageScore(List<InterviewApiModel> interviews) {
    final scores = interviews
        .map((item) => item.myLatestScore)
        .whereType<double>()
        .toList();

    if (scores.isEmpty) return 0;

    final total = scores.reduce((sum, item) => sum + item);
    return total / scores.length;
  }

  List<InterviewApiModel> _mergeInterviews(
    List<InterviewApiModel> first,
    List<InterviewApiModel> second,
  ) {
    final map = <String, InterviewApiModel>{};
    for (final interview in [...first, ...second]) {
      map.putIfAbsent(interview.id, () => interview);
    }

    final merged = map.values.toList();
    merged.sort((left, right) {
      final leftTime =
          DateTime.tryParse(left.updatedAt)?.millisecondsSinceEpoch ?? 0;
      final rightTime =
          DateTime.tryParse(right.updatedAt)?.millisecondsSinceEpoch ?? 0;
      return rightTime.compareTo(leftTime);
    });
    return merged;
  }

  @override
  Future<InterviewsSectionApiModel> getInterviewsSection({
    String? searchQuery,
    String? interviewType,
    String? status,
    String? sortBy,
    String? attemptFilter,
  }) async {
    final normalizedAttempt = (attemptFilter ?? '').trim();
    final normalizedSort = _normalizeInterviewSort(sortBy);
    final baseOwnership = _ownershipForAttemptFilter(normalizedAttempt);
    final normalizedSearch = (searchQuery ?? '').trim();
    final normalizedType = (interviewType ?? '').trim();
    final normalizedStatus = (status ?? '').trim();

    final results = await Future.wait([
      _fetchInterviews(
        ownership: baseOwnership,
        sortBy: normalizedSort ?? 'newest',
        searchQuery: normalizedSearch,
        interviewType: normalizedType,
        status: normalizedStatus,
      ),
      _fetchInterviews(
        ownership: baseOwnership,
        sortBy: normalizedSort ?? 'popular',
        searchQuery: normalizedSearch,
        interviewType: normalizedType,
        status: normalizedStatus,
      ),
      _fetchInterviews(
        ownership: 'created_by_me',
        sortBy: normalizedSort ?? 'updated',
        searchQuery: normalizedSearch,
        interviewType: normalizedType,
        status: normalizedStatus,
      ),
      _fetchInterviews(
        ownership: 'taken_by_me',
        sortBy: normalizedSort ?? 'updated',
        searchQuery: normalizedSearch,
        interviewType: normalizedType,
        status: normalizedStatus,
        allowForbidden: true,
      ),
    ]);

    final forYou = results[0];
    final trending = results[1];
    final byYou = results[2];
    final takenByMe = results[3];

    final newThisWeek = [...forYou]
      ..sort((left, right) {
        final leftTime =
            DateTime.tryParse(left.createdAt)?.millisecondsSinceEpoch ?? 0;
        final rightTime =
            DateTime.tryParse(right.createdAt)?.millisecondsSinceEpoch ?? 0;
        return rightTime.compareTo(leftTime);
      });

    final allTimePopular = [...trending];
    final drafts = byYou.where((item) => item.status == 'draft').toList();
    final allInterviews = _mergeInterviews(forYou, byYou);

    return InterviewsSectionApiModel(
      forYou: forYou,
      trending: trending,
      newThisWeek: newThisWeek,
      allTimePopular: allTimePopular,
      byYou: byYou,
      all: allInterviews,
      createdByMe: byYou,
      takenByMe: takenByMe,
      drafts: drafts,
      averageScore: _calculateAverageScore(takenByMe),
      lastUpdatedAt: allInterviews.isEmpty
          ? null
          : allInterviews.first.updatedAt,
    );
  }

  @override
  Future<InterviewApiModel> getInterviewById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.interviewById(id));
    final data = _extractDataMap(response);
    final interview = _asMap(data['interview']) ?? data;
    return InterviewApiModel.fromApiResponse(interview);
  }

  @override
  Future<InterviewApiModel> createInterview({
    required String title,
    String? description,
    required String interviewType,
    required String role,
    String? level,
    List<String>? techStack,
    int? questionCount,
    int? durationMinutes,
    String? visibility,
    String? status,
    List<String>? tags,
    String? instructions,
    bool? generateQuestions,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.interviews,
      data: {
        'title': title,
        'interviewType': interviewType,
        'role': role,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (level != null && level.isNotEmpty) 'level': level,
        if (techStack != null && techStack.isNotEmpty) 'techStack': techStack,
        if (questionCount != null) 'questionCount': questionCount,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (visibility != null && visibility.isNotEmpty)
          'visibility': visibility,
        if (status != null && status.isNotEmpty) 'status': status,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        if (instructions != null && instructions.isNotEmpty)
          'instructions': instructions,
        if (generateQuestions != null) 'generateQuestions': generateQuestions,
      },
    );
    final data = _extractDataMap(response);
    final interview = _asMap(data['interview']) ?? data;
    return InterviewApiModel.fromApiResponse(interview);
  }

  @override
  Future<InterviewApiModel> updateInterview({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.interviewById(id),
      data: data,
    );
    final responseData = _extractDataMap(response);
    final interview = _asMap(responseData['interview']) ?? responseData;
    return InterviewApiModel.fromApiResponse(interview);
  }

  @override
  Future<bool> deleteInterview(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.interviewById(id));
    final body = response.data;
    if (body is Map) {
      return _castMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<InterviewSessionStartApiModel> startInterviewSession(
    String interviewId,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.interviewSessions(interviewId),
      data: {
        'mode': 'mobile',
        'metadata': {'source': 'mobile_interview_hub'},
      },
    );
    final data = _extractDataMap(response);
    return InterviewSessionStartApiModel.fromResponseData(data);
  }

  @override
  Future<bool> completeSession({
    required String interviewId,
    required String sessionId,
    required String status,
    List<Map<String, dynamic>>? transcript,
    String? recordingUrl,
    int? durationSeconds,
    String? vapiCallId,
    bool generateEvaluation = true,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.completeInterviewSession(interviewId, sessionId),
      data: {
        'status': status,
        if (transcript != null && transcript.isNotEmpty)
          'transcript': transcript,
        if (recordingUrl != null && recordingUrl.isNotEmpty)
          'recordingUrl': recordingUrl,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (vapiCallId != null && vapiCallId.isNotEmpty)
          'vapiCallId': vapiCallId,
        'generateEvaluation': generateEvaluation,
      },
    );
    final body = response.data;
    if (body is Map) {
      return _castMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<List<InterviewSessionApiModel>> listMySessions(
    String interviewId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.interviewMySessionsById(interviewId),
    );
    final data = _extractDataMap(response);
    return InterviewSessionApiModel.fromApiList(data['sessions']);
  }

  @override
  Future<InterviewFeedbackApiModel> getInterviewFeedback(
    String sessionId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.interviewSessionFeedback(sessionId),
    );
    final data = _extractDataMap(response);
    return InterviewFeedbackApiModel.fromResponseData(data);
  }

  @override
  Future<InterviewAnalyticsApiModel> getInterviewAnalytics(
    String interviewId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.interviewAnalytics(interviewId),
    );
    final data = _extractDataMap(response);
    return InterviewAnalyticsApiModel.fromResponseData(data);
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
  Future<bool> setInterviewSaved({
    required String interviewId,
    required bool isSaved,
  }) async {
    final endpoint = ApiEndpoints.bookmarkInterview(interviewId);
    final response = isSaved
        ? await _apiClient.post(endpoint)
        : await _apiClient.delete(endpoint);
    return _isBookmarkSuccess(response);
  }
}
