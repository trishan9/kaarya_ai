import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_analytics_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_feedback_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_section_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_session_entity.dart';

part 'interview_api_model.g.dart';

@JsonSerializable()
class InterviewApiModel {
  final String id;
  final String title;
  final String role;
  final String interviewType;
  final String status;
  final String source;
  final String companyName;
  final String? companyLogo;
  final int attemptsCount;
  final double? myLatestScore;
  final String? myLatestSessionId;
  final bool hasAttempted;
  final bool isSaved;
  final List<String> techStack;
  @JsonKey(defaultValue: [])
  final List<String> techStackIconUrls;
  final String createdAt;
  final String updatedAt;

  const InterviewApiModel({
    required this.id,
    required this.title,
    required this.role,
    required this.interviewType,
    required this.status,
    required this.source,
    required this.companyName,
    required this.companyLogo,
    required this.attemptsCount,
    required this.myLatestScore,
    required this.myLatestSessionId,
    required this.hasAttempted,
    required this.isSaved,
    required this.techStack,
    this.techStackIconUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory InterviewApiModel.fromJson(Map<String, dynamic> json) =>
      _$InterviewApiModelFromJson(json);

  factory InterviewApiModel.fromApiResponse(Map<String, dynamic> json) {
    final company = jsonAsMap(json['company']);
    final college = jsonAsMap(json['college']);
    final (techNames, techIconUrls) = jsonTechStack(json['techStack']);

    return InterviewApiModel(
      id: jsonString(json['id']),
      title: jsonString(json['title'], fallback: 'Untitled Interview'),
      role: jsonString(json['role']),
      interviewType: jsonString(json['interviewType'], fallback: 'mixed'),
      status: jsonString(json['status'], fallback: 'draft'),
      source: jsonString(json['source'], fallback: 'candidate'),
      companyName:
          jsonNullableString(company?['name']) ??
          jsonNullableString(college?['name']) ??
          'Kaarya',
      companyLogo:
          jsonNullableString(company?['logo']) ??
          jsonNullableString(college?['logo']),
      attemptsCount: jsonInt(json['attemptsCount']),
      myLatestScore: jsonDoubleOrNull(json['myLatestScore']),
      myLatestSessionId: jsonNullableString(json['myLatestSessionId']),
      hasAttempted: jsonBool(json['hasAttempted']),
      isSaved: jsonBool(json['isSaved']),
      techStack: techNames,
      techStackIconUrls: techIconUrls,
      createdAt: jsonString(json['createdAt']),
      updatedAt: jsonString(json['updatedAt']),
    );
  }

  static List<InterviewApiModel> fromApiList(dynamic interviews) {
    if (interviews is! List) return const <InterviewApiModel>[];

    return interviews
        .whereType<Map>()
        .map((item) => InterviewApiModel.fromApiResponse(jsonCastMap(item)))
        .toList();
  }

  static List<InterviewApiModel> fromCacheList(dynamic interviews) {
    if (interviews is! List) return const <InterviewApiModel>[];

    return interviews
        .whereType<Map>()
        .map((item) => InterviewApiModel.fromJson(jsonCastMap(item)))
        .toList();
  }

  Map<String, dynamic> toJson() => _$InterviewApiModelToJson(this);

  InterviewEntity toEntity() {
    return InterviewEntity(
      id: id,
      title: title,
      role: role,
      interviewType: interviewType,
      status: status,
      source: source,
      companyName: companyName,
      companyLogo: companyLogo,
      attemptsCount: attemptsCount,
      myLatestScore: myLatestScore,
      myLatestSessionId: myLatestSessionId,
      hasAttempted: hasAttempted,
      isSaved: isSaved,
      techStack: techStack,
      techStackIconUrls: techStackIconUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class InterviewsSectionApiModel {
  final List<InterviewApiModel> forYou;
  final List<InterviewApiModel> trending;
  final List<InterviewApiModel> newThisWeek;
  final List<InterviewApiModel> allTimePopular;
  final List<InterviewApiModel> byYou;
  final List<InterviewApiModel> all;
  final List<InterviewApiModel> createdByMe;
  final List<InterviewApiModel> takenByMe;
  final List<InterviewApiModel> drafts;
  final double averageScore;
  final String? lastUpdatedAt;

  const InterviewsSectionApiModel({
    required this.forYou,
    required this.trending,
    required this.newThisWeek,
    required this.allTimePopular,
    required this.byYou,
    required this.all,
    required this.createdByMe,
    required this.takenByMe,
    required this.drafts,
    required this.averageScore,
    required this.lastUpdatedAt,
  });

  factory InterviewsSectionApiModel.fromJson(Map<String, dynamic> json) {
    return InterviewsSectionApiModel(
      forYou: InterviewApiModel.fromCacheList(json['forYou']),
      trending: InterviewApiModel.fromCacheList(json['trending']),
      newThisWeek: InterviewApiModel.fromCacheList(json['newThisWeek']),
      allTimePopular: InterviewApiModel.fromCacheList(json['allTimePopular']),
      byYou: InterviewApiModel.fromCacheList(json['byYou']),
      all: InterviewApiModel.fromCacheList(json['all']),
      createdByMe: InterviewApiModel.fromCacheList(json['createdByMe']),
      takenByMe: InterviewApiModel.fromCacheList(json['takenByMe']),
      drafts: InterviewApiModel.fromCacheList(json['drafts']),
      averageScore: jsonDouble(json['averageScore']),
      lastUpdatedAt: jsonNullableString(json['lastUpdatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forYou': forYou.map((item) => item.toJson()).toList(),
      'trending': trending.map((item) => item.toJson()).toList(),
      'newThisWeek': newThisWeek.map((item) => item.toJson()).toList(),
      'allTimePopular': allTimePopular.map((item) => item.toJson()).toList(),
      'byYou': byYou.map((item) => item.toJson()).toList(),
      'all': all.map((item) => item.toJson()).toList(),
      'createdByMe': createdByMe.map((item) => item.toJson()).toList(),
      'takenByMe': takenByMe.map((item) => item.toJson()).toList(),
      'drafts': drafts.map((item) => item.toJson()).toList(),
      'averageScore': averageScore,
      'lastUpdatedAt': lastUpdatedAt,
    };
  }

  InterviewsSectionEntity toEntity() {
    return InterviewsSectionEntity(
      forYou: forYou.map((item) => item.toEntity()).toList(),
      trending: trending.map((item) => item.toEntity()).toList(),
      newThisWeek: newThisWeek.map((item) => item.toEntity()).toList(),
      allTimePopular: allTimePopular.map((item) => item.toEntity()).toList(),
      byYou: byYou.map((item) => item.toEntity()).toList(),
      all: all.map((item) => item.toEntity()).toList(),
      createdByMe: createdByMe.map((item) => item.toEntity()).toList(),
      takenByMe: takenByMe.map((item) => item.toEntity()).toList(),
      drafts: drafts.map((item) => item.toEntity()).toList(),
      averageScore: averageScore,
      lastUpdatedAt: lastUpdatedAt,
    );
  }
}

class InterviewSessionStartApiModel {
  final String sessionId;
  final String? interviewId;

  const InterviewSessionStartApiModel({
    required this.sessionId,
    required this.interviewId,
  });

  factory InterviewSessionStartApiModel.fromResponseData(
    Map<String, dynamic> data,
  ) {
    final session = jsonAsMap(data['session']) ?? const <String, dynamic>{};
    final interview = jsonAsMap(data['interview']) ?? const <String, dynamic>{};
    return InterviewSessionStartApiModel(
      sessionId: jsonString(session['id']),
      interviewId: jsonNullableString(interview['id']),
    );
  }

  InterviewSessionStartEntity toEntity() {
    return InterviewSessionStartEntity(
      sessionId: sessionId,
      interviewId: interviewId,
    );
  }
}

class InterviewSessionApiModel {
  final String id;
  final String interviewId;
  final String userId;
  final String status;
  final int durationSeconds;
  final double? totalScore;
  final String createdAt;

  const InterviewSessionApiModel({
    required this.id,
    required this.interviewId,
    required this.userId,
    required this.status,
    required this.durationSeconds,
    required this.totalScore,
    required this.createdAt,
  });

  factory InterviewSessionApiModel.fromJson(Map<String, dynamic> json) {
    return InterviewSessionApiModel(
      id: jsonString(json['id']),
      interviewId: jsonString(json['interviewId']),
      userId: jsonString(json['userId']),
      status: jsonString(json['status'], fallback: 'started'),
      durationSeconds: jsonInt(json['durationSeconds']),
      totalScore: jsonDoubleOrNull(json['totalScore']),
      createdAt: jsonString(json['createdAt']),
    );
  }

  static List<InterviewSessionApiModel> fromApiList(dynamic sessions) {
    if (sessions is! List) return const <InterviewSessionApiModel>[];

    return sessions
        .whereType<Map>()
        .map((item) => InterviewSessionApiModel.fromJson(jsonCastMap(item)))
        .toList();
  }

  InterviewSessionEntity toEntity() {
    return InterviewSessionEntity(
      id: id,
      interviewId: interviewId,
      userId: userId,
      status: status,
      durationSeconds: durationSeconds,
      totalScore: totalScore,
      createdAt: createdAt,
    );
  }
}

class InterviewFeedbackApiModel {
  final String sessionId;
  final String interviewTitle;
  final double? totalScore;
  final String? finalAssessment;
  final List<InterviewCategoryScoreApiModel> categoryScores;

  const InterviewFeedbackApiModel({
    required this.sessionId,
    required this.interviewTitle,
    required this.totalScore,
    required this.finalAssessment,
    required this.categoryScores,
  });

  factory InterviewFeedbackApiModel.fromResponseData(
    Map<String, dynamic> data,
  ) {
    final interview = jsonAsMap(data['interview']) ?? const <String, dynamic>{};
    final session = jsonAsMap(data['session']) ?? const <String, dynamic>{};
    final evaluation =
        jsonAsMap(data['evaluation']) ?? const <String, dynamic>{};

    return InterviewFeedbackApiModel(
      sessionId: jsonString(session['id']),
      interviewTitle: jsonString(interview['title'], fallback: 'Interview'),
      totalScore: jsonDoubleOrNull(evaluation['totalScore']),
      finalAssessment: jsonNullableString(evaluation['finalAssessment']),
      categoryScores: InterviewCategoryScoreApiModel.fromApiList(
        evaluation['categoryScores'],
      ),
    );
  }

  InterviewFeedbackEntity toEntity() {
    return InterviewFeedbackEntity(
      sessionId: sessionId,
      interviewTitle: interviewTitle,
      totalScore: totalScore,
      finalAssessment: finalAssessment,
      categoryScores: categoryScores.map((item) => item.toEntity()).toList(),
    );
  }
}

class InterviewCategoryScoreApiModel {
  final String category;
  final double score;
  final String? feedback;

  const InterviewCategoryScoreApiModel({
    required this.category,
    required this.score,
    required this.feedback,
  });

  factory InterviewCategoryScoreApiModel.fromJson(Map<String, dynamic> json) {
    return InterviewCategoryScoreApiModel(
      category: jsonString(json['category']),
      score: jsonDouble(json['score']),
      feedback: jsonNullableString(json['feedback']),
    );
  }

  static List<InterviewCategoryScoreApiModel> fromApiList(dynamic scores) {
    if (scores is! List) return const <InterviewCategoryScoreApiModel>[];

    return scores
        .whereType<Map>()
        .map(
          (item) => InterviewCategoryScoreApiModel.fromJson(jsonCastMap(item)),
        )
        .toList();
  }

  InterviewCategoryScoreEntity toEntity() {
    return InterviewCategoryScoreEntity(
      category: category,
      score: score,
      feedback: feedback,
    );
  }
}

class InterviewAnalyticsApiModel {
  final int totalSessions;
  final double completionRate;
  final double averageScore;
  final List<InterviewScoreDistributionApiModel> scoreDistribution;

  const InterviewAnalyticsApiModel({
    required this.totalSessions,
    required this.completionRate,
    required this.averageScore,
    required this.scoreDistribution,
  });

  factory InterviewAnalyticsApiModel.fromResponseData(
    Map<String, dynamic> data,
  ) {
    return InterviewAnalyticsApiModel(
      totalSessions: jsonInt(data['totalSessions']),
      completionRate: jsonDouble(data['completionRate']),
      averageScore: jsonDouble(data['averageScore']),
      scoreDistribution: InterviewScoreDistributionApiModel.fromApiList(
        data['scoreDistribution'],
      ),
    );
  }

  InterviewAnalyticsEntity toEntity() {
    return InterviewAnalyticsEntity(
      totalSessions: totalSessions,
      completionRate: completionRate,
      averageScore: averageScore,
      scoreDistribution: scoreDistribution
          .map((item) => item.toEntity())
          .toList(),
    );
  }
}

class InterviewScoreDistributionApiModel {
  final String range;
  final int count;

  const InterviewScoreDistributionApiModel({
    required this.range,
    required this.count,
  });

  factory InterviewScoreDistributionApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InterviewScoreDistributionApiModel(
      range: jsonString(json['range']),
      count: jsonInt(json['count']),
    );
  }

  static List<InterviewScoreDistributionApiModel> fromApiList(dynamic items) {
    if (items is! List) return const <InterviewScoreDistributionApiModel>[];

    return items
        .whereType<Map>()
        .map(
          (item) =>
              InterviewScoreDistributionApiModel.fromJson(jsonCastMap(item)),
        )
        .toList();
  }

  InterviewScoreDistributionEntity toEntity() {
    return InterviewScoreDistributionEntity(range: range, count: count);
  }
}
