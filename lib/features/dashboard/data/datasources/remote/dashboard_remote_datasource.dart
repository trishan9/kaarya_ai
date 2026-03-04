import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:kaarya/features/dashboard/data/models/dashboard_api_models.dart';
import 'package:kaarya/features/dashboard/data/models/extra_api_models.dart';

final dashboardRemoteDatasourceProvider = Provider<IDashboardRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return DashboardRemoteDatasource(apiClient: apiClient);
});

class DashboardRemoteDatasource implements IDashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<DashboardOverviewApiModel> getOverviewData({String? monthKey}) async {
    final normalizedMonth = _normalizeMonthKey(monthKey);

    final forYouJobs = await _fetchJobs(feed: 'for_you');
    final trendingJobs = await _fetchJobs(feed: 'trending');
    final newThisWeekJobs = await _fetchJobs(feed: 'last_week');
    final remoteJobs = await _fetchJobs(feed: 'for_you', remoteOnly: true);
    final summaryBundle = await _fetchApplicationsSummaryBundle(
      monthKey: normalizedMonth,
    );
    final invitation = await _fetchInterviewInvitation();
    final profileRating = await _fetchProfileRating();
    final takenInterviews = await _fetchInterviews(
      ownership: 'taken_by_me',
      sortBy: 'updated',
      allowForbidden: true,
    );

    final urgentJobs = _buildUrgentJobs(forYouJobs);

    return DashboardOverviewApiModel(
      summary: summaryBundle.summary,
      deadlineJob: _findNearestDeadlineJob(forYouJobs),
      invitation: invitation,
      jobs: DashboardJobsBucketApiModel(
        forYou: forYouJobs,
        trending: trendingJobs,
        newThisWeek: newThisWeekJobs,
        remote: remoteJobs,
        urgent: urgentJobs,
      ),
      readinessPoints: _buildReadinessPoints(takenInterviews),
      analytics: summaryBundle.analytics,
      profileRating: profileRating,
      interviewOverallRating: _calculateAverageInterviewScore(takenInterviews),
    );
  }

  @override
  Future<ProfilePreferencesApiModel> getProfilePreferences() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    final data = _extractDataMap(response);
    return ProfilePreferencesApiModel.fromUserJson(data);
  }

  Future<List<DashboardJobApiModel>> _fetchJobs({
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
    return DashboardJobApiModel.fromApiList(data['jobs']);
  }

  Future<_ApplicationsSummaryBundle> _fetchApplicationsSummaryBundle({
    required String monthKey,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.myApplicationsSummary,
      queryParameters: {'month': monthKey},
    );

    final data = _extractDataMap(response);
    final normalizedData = _normalizeSummaryPayload(data, monthKey: monthKey);
    return _ApplicationsSummaryBundle(
      summary: DashboardApplicationsSummaryApiModel.fromSummaryData(
        normalizedData,
      ),
      analytics: DashboardAnalyticsApiModel.fromSummaryData(normalizedData),
    );
  }

  Future<DashboardInvitationApiModel?> _fetchInterviewInvitation() async {
    final response = await _apiClient.get(
      ApiEndpoints.myApplications,
      queryParameters: {'page': 1, 'size': 50, 'status': 'interview_scheduled'},
    );

    final data = _extractDataMap(response);
    final applications = data['applications'];
    if (applications is! List) {
      return null;
    }

    final now = DateTime.now();
    final upcoming =
        applications.whereType<Map>().map((item) => _castMap(item)).where((
          application,
        ) {
          final scheduledAt = _parseDateTime(
            _nullableString(application['interviewScheduledAt']),
          );
          return scheduledAt != null && !scheduledAt.isBefore(now);
        }).toList()..sort((left, right) {
          final leftTs =
              _parseDateTime(
                _nullableString(left['interviewScheduledAt']),
              )?.millisecondsSinceEpoch ??
              0;
          final rightTs =
              _parseDateTime(
                _nullableString(right['interviewScheduledAt']),
              )?.millisecondsSinceEpoch ??
              0;
          return leftTs.compareTo(rightTs);
        });

    if (upcoming.isEmpty) {
      return null;
    }

    final invitation = upcoming.first;
    final job = _asMap(invitation['job']);
    final company = _asMap(job?['company']) ?? _asMap(job?['college']);
    final interviewScheduledAt = _nullableString(
      invitation['interviewScheduledAt'],
    );
    final scheduleDate = _parseDateTime(interviewScheduledAt);

    return DashboardInvitationApiModel(
      title: 'Interview invitation received',
      description:
          'A recruiter invited you for an interview. Review the schedule and prepare your next steps.',
      eventTitle: scheduleDate == null
          ? 'Schedule pending'
          : _formatDateLabel(scheduleDate),
      eventTime: scheduleDate == null
          ? 'Time will be shared soon'
          : _formatTimeLabel(scheduleDate),
      companyName: _nullableString(company?['name']),
      companyLogo: _nullableString(company?['logo']),
      interviewScheduledAt: interviewScheduledAt,
    );
  }

  Future<List<DashboardInterviewApiModel>> _fetchInterviews({
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
      return DashboardInterviewApiModel.fromApiList(data['interviews']);
    } on DioException catch (e) {
      if (allowForbidden && e.response?.statusCode == 403) {
        return const <DashboardInterviewApiModel>[];
      }
      rethrow;
    }
  }

  Future<double> _fetchProfileRating() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);
      final data = _extractDataMap(response);
      final direct = _resolveDirectProfileRating(data);
      if (direct != null) {
        return direct;
      }
      return _computeProfileCompletionRating(data);
    } catch (_) {
      return 0;
    }
  }

  double? _resolveDirectProfileRating(Map<String, dynamic> user) {
    final ratingMap = _asMap(user['profileRating']);
    if (ratingMap != null) {
      final score =
          _doubleOrNull(ratingMap['overall']) ??
          _doubleOrNull(ratingMap['completion']) ??
          _doubleOrNull(ratingMap['score']);
      if (score != null) return score.clamp(0, 100).toDouble();
    }

    final direct = _doubleOrNull(user['profileRating']);
    if (direct != null) {
      return direct.clamp(0, 100).toDouble();
    }

    return null;
  }

  double _computeProfileCompletionRating(Map<String, dynamic> user) {
    final profile =
        _asMap(user['candidateProfile']) ?? const <String, dynamic>{};

    final skills = _asList(profile['skills']);
    final preferredRoles = _listLength(profile['preferredRoles']);
    final preferredWorkModes = _listLength(profile['preferredWorkModes']);
    final experience = _asList(profile['experience']);
    final education = _asList(profile['education']);
    final certifications = _asList(profile['certifications']);
    final portfolioLinks = _listLength(profile['portfolioLinks']);
    final salary = _asMap(profile['salary']) ?? const <String, dynamic>{};

    final basicInfo =
        (_hasValue(user['name']) ? 4 : 0) +
        (_hasValue(user['email']) ? 2 : 0) +
        (_hasValue(user['photo']) ? 5 : 0) +
        (_hasValue(profile['headline']) ? 5 : 0) +
        (_hasValue(profile['summary']) ? 4 : 0) +
        (_hasValue(profile['phone']) ? 2 : 0) +
        (_hasValue(profile['location']) ? 3 : 0);

    final hasAdvancedSkill = skills.any((skill) {
      final proficiency = _nullableString(skill['proficiency'])?.toLowerCase();
      return proficiency == 'advanced' ||
          proficiency == 'expert' ||
          proficiency == 'master';
    });
    final categories = skills
        .map((skill) => _nullableString(skill['category'])?.toLowerCase())
        .whereType<String>()
        .toSet();

    final skillsScore =
        (skills.isNotEmpty ? 4 : 0) +
        (skills.length >= 3 ? 4 : 0) +
        (skills.length >= 5 ? 3 : 0) +
        (hasAdvancedSkill ? 5 : 0) +
        (categories.length >= 2 ? 3 : 0) +
        (preferredRoles >= 1 ? 3 : 0) +
        (preferredWorkModes >= 1 ? 3 : 0);

    final hasDetailedExperience = experience.any((item) {
      final description = _nullableString(item['description']) ?? '';
      return description.length > 50;
    });
    final hasFieldOfStudy = education.any(
      (item) => _hasValue(item['fieldOfStudy']),
    );
    final hasCredentialUrl = certifications.any(
      (item) => _hasValue(item['credentialUrl']),
    );

    final experienceEducation =
        (experience.isNotEmpty ? 5 : 0) +
        (hasDetailedExperience ? 5 : 0) +
        (education.isNotEmpty ? 5 : 0) +
        (hasFieldOfStudy ? 3 : 0) +
        (certifications.isNotEmpty ? 4 : 0) +
        (hasCredentialUrl ? 3 : 0);

    final resumeAndLinks =
        (_hasValue(profile['defaultResumeId']) ? 8 : 0) +
        (_hasValue(profile['linkedinUrl']) ? 4 : 0) +
        (_hasValue(profile['githubUrl']) ? 3 : 0) +
        (_hasValue(profile['portfolioUrl']) ? 3 : 0) +
        (portfolioLinks >= 1 ? 2 : 0) +
        (_doubleOrNull(salary['minAmount']) != null ? 3 : 0) +
        (_hasValue(salary['currency']) ? 2 : 0);

    final total =
        basicInfo + skillsScore + experienceEducation + resumeAndLinks;
    return total.clamp(0, 100).toDouble();
  }

  bool _hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  int _listLength(dynamic value) {
    if (value is List) return value.length;
    return 0;
  }

  double? _doubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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

  DashboardJobApiModel? _findNearestDeadlineJob(
    List<DashboardJobApiModel> jobs,
  ) {
    final now = DateTime.now();

    final valid =
        jobs.where((job) => job.status == 'open').where((job) {
          final deadline = _parseDateTime(job.deadline);
          return deadline != null && !deadline.isBefore(now);
        }).toList()..sort((left, right) {
          final leftTime =
              _parseDateTime(left.deadline)?.millisecondsSinceEpoch ?? 0;
          final rightTime =
              _parseDateTime(right.deadline)?.millisecondsSinceEpoch ?? 0;
          return leftTime.compareTo(rightTime);
        });

    return valid.isEmpty ? null : valid.first;
  }

  List<DashboardJobApiModel> _buildUrgentJobs(List<DashboardJobApiModel> jobs) {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 3));

    final urgent = jobs.where((job) {
      if (job.status != 'open') return false;
      final deadline = _parseDateTime(job.deadline);
      if (deadline == null) return false;
      return !deadline.isBefore(now) && !deadline.isAfter(threshold);
    }).toList();

    return urgent;
  }

  List<DashboardInterviewReadinessPointApiModel> _buildReadinessPoints(
    List<DashboardInterviewApiModel> interviews,
  ) {
    final scored =
        interviews.where((item) => item.myLatestScore != null).toList()
          ..sort((left, right) {
            final leftTime =
                _parseDateTime(left.updatedAt)?.millisecondsSinceEpoch ?? 0;
            final rightTime =
                _parseDateTime(right.updatedAt)?.millisecondsSinceEpoch ?? 0;
            return leftTime.compareTo(rightTime);
          });

    if (scored.isEmpty) {
      return const <DashboardInterviewReadinessPointApiModel>[];
    }

    final window = scored.length > 5
        ? scored.sublist(scored.length - 5)
        : scored;
    return List.generate(window.length, (index) {
      return DashboardInterviewReadinessPointApiModel(
        label: 'Week ${index + 1}',
        score: window[index].myLatestScore ?? 0,
      );
    });
  }

  double _calculateAverageInterviewScore(
    List<DashboardInterviewApiModel> interviews,
  ) {
    final scores = interviews
        .map((item) => item.myLatestScore)
        .whereType<double>()
        .toList();

    if (scores.isEmpty) {
      return 0;
    }

    final total = scores.reduce((sum, item) => sum + item);
    return total / scores.length;
  }

  String _currentMonthKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    return '${now.year}-$month';
  }

  String _normalizeMonthKey(String? monthKey) {
    final normalized = (monthKey ?? '').trim();
    final regex = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');
    if (regex.hasMatch(normalized)) {
      return normalized;
    }

    return _currentMonthKey();
  }

  Map<String, dynamic> _normalizeSummaryPayload(
    Map<String, dynamic> payload, {
    required String monthKey,
  }) {
    final month = _asMap(payload['month']) ?? const <String, dynamic>{};
    if (_nullableString(month['key']) != null &&
        _nullableString(month['label']) != null) {
      return payload;
    }

    final normalized = <String, dynamic>{...payload};
    normalized['month'] = {
      'key': _nullableString(month['key']) ?? monthKey,
      'label': _nullableString(month['label']) ?? _formatMonthLabel(monthKey),
    };
    return normalized;
  }

  String _formatMonthLabel(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) {
      return 'Current Month';
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null || month < 1 || month > 12) {
      return 'Current Month';
    }

    final date = DateTime(year, month, 1);
    return '${_monthName(date.month)} ${date.year}';
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toLocal();
  }

  String _formatDateLabel(DateTime value) {
    return '${_weekDayName(value.weekday)}, ${_monthName(value.month)} ${value.day}, ${value.year}';
  }

  String _formatTimeLabel(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final meridian = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $meridian';
  }

  String _weekDayName(int weekDay) {
    switch (weekDay) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      default:
        return 'Sunday';
    }
  }

  String _monthName(int month) {
    switch (month) {
      case DateTime.january:
        return 'January';
      case DateTime.february:
        return 'February';
      case DateTime.march:
        return 'March';
      case DateTime.april:
        return 'April';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'June';
      case DateTime.july:
        return 'July';
      case DateTime.august:
        return 'August';
      case DateTime.september:
        return 'September';
      case DateTime.october:
        return 'October';
      case DateTime.november:
        return 'November';
      default:
        return 'December';
    }
  }

  Map<String, dynamic> _castMap(Map value) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return _castMap(value);
    return null;
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.whereType<Map>().map(_castMap).toList();
  }

  String? _nullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }
}

class _ApplicationsSummaryBundle {
  final DashboardApplicationsSummaryApiModel summary;
  final DashboardAnalyticsApiModel analytics;

  const _ApplicationsSummaryBundle({
    required this.summary,
    required this.analytics,
  });
}
