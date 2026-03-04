import 'package:equatable/equatable.dart';

class CollegeWorkspaceEntity extends Equatable {
  final String collegeId;
  final String collegeName;
  final String? collegeLogo;
  final String joinedAt;

  const CollegeWorkspaceEntity({
    required this.collegeId,
    required this.collegeName,
    this.collegeLogo,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [collegeId, collegeName, collegeLogo, joinedAt];
}
