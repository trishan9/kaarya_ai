import 'package:equatable/equatable.dart';

class AtsScanTipEntity extends Equatable {
  final String type;
  final String tip;
  final String? explanation;

  const AtsScanTipEntity({
    required this.type,
    required this.tip,
    this.explanation,
  });

  bool get isGood => type == 'good';

  @override
  List<Object?> get props => [type, tip, explanation];
}

class AtsScanCategoryEntity extends Equatable {
  final double score;
  final List<AtsScanTipEntity> tips;

  const AtsScanCategoryEntity({required this.score, required this.tips});

  int get strengthsCount => tips.where((t) => t.isGood).length;
  int get improvementsCount => tips.where((t) => !t.isGood).length;

  @override
  List<Object?> get props => [score, tips];
}

class AtsScanResultEntity extends Equatable {
  final double overallScore;
  final String? documentType;
  final String? classificationReason;
  final AtsScanCategoryEntity? ats;
  final AtsScanCategoryEntity? toneAndStyle;
  final AtsScanCategoryEntity? content;
  final AtsScanCategoryEntity? structure;
  final AtsScanCategoryEntity? skills;

  const AtsScanResultEntity({
    required this.overallScore,
    this.documentType,
    this.classificationReason,
    this.ats,
    this.toneAndStyle,
    this.content,
    this.structure,
    this.skills,
  });

  bool get isNotResume => documentType == 'not_resume';

  List<AtsScanCategoryEntity> get categories => [
    if (ats != null) ats!,
    if (toneAndStyle != null) toneAndStyle!,
    if (content != null) content!,
    if (structure != null) structure!,
    if (skills != null) skills!,
  ];

  int get totalStrengths =>
      categories.fold(0, (sum, c) => sum + c.strengthsCount);

  int get totalImprovements =>
      categories.fold(0, (sum, c) => sum + c.improvementsCount);

  @override
  List<Object?> get props => [
    overallScore,
    documentType,
    classificationReason,
    ats,
    toneAndStyle,
    content,
    structure,
    skills,
  ];
}
