import 'package:equatable/equatable.dart';

class AtsScanResultEntity extends Equatable {
  final double overallScore;
  final double atsScore;
  final double toneStyleScore;
  final double contentScore;
  final double structureScore;
  final double skillsScore;
  final List<String> suggestions;
  final List<String> improvements;

  const AtsScanResultEntity({
    required this.overallScore,
    required this.atsScore,
    required this.toneStyleScore,
    required this.contentScore,
    required this.structureScore,
    required this.skillsScore,
    required this.suggestions,
    required this.improvements,
  });

  @override
  List<Object?> get props => [
    overallScore,
    atsScore,
    toneStyleScore,
    contentScore,
    structureScore,
    skillsScore,
    suggestions,
    improvements,
  ];
}
