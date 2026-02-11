import 'package:equatable/equatable.dart';

class InterviewEntity extends Equatable {
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
  final List<String> techStackIconUrls;
  final String createdAt;
  final String updatedAt;

  const InterviewEntity({
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

  InterviewEntity copyWith({
    String? id,
    String? title,
    String? role,
    String? interviewType,
    String? status,
    String? source,
    String? companyName,
    String? companyLogo,
    int? attemptsCount,
    double? myLatestScore,
    String? myLatestSessionId,
    bool? hasAttempted,
    bool? isSaved,
    List<String>? techStack,
    List<String>? techStackIconUrls,
    String? createdAt,
    String? updatedAt,
  }) {
    return InterviewEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      role: role ?? this.role,
      interviewType: interviewType ?? this.interviewType,
      status: status ?? this.status,
      source: source ?? this.source,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      myLatestScore: myLatestScore ?? this.myLatestScore,
      myLatestSessionId: myLatestSessionId ?? this.myLatestSessionId,
      hasAttempted: hasAttempted ?? this.hasAttempted,
      isSaved: isSaved ?? this.isSaved,
      techStack: techStack ?? this.techStack,
      techStackIconUrls: techStackIconUrls ?? this.techStackIconUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    role,
    interviewType,
    status,
    source,
    companyName,
    companyLogo,
    attemptsCount,
    myLatestScore,
    myLatestSessionId,
    hasAttempted,
    isSaved,
    techStack,
    techStackIconUrls,
    createdAt,
    updatedAt,
  ];
}
