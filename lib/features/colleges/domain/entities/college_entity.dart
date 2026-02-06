import 'package:equatable/equatable.dart';

class CollegeEntity extends Equatable {
  final String id;
  final String name;
  final String institutionType;
  final String location;
  final String? logo;
  final String? inviteCode;
  final int studentsCount;
  final String createdAt;

  const CollegeEntity({
    required this.id,
    required this.name,
    required this.institutionType,
    required this.location,
    this.logo,
    this.inviteCode,
    required this.studentsCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    institutionType,
    location,
    logo,
    inviteCode,
    studentsCount,
    createdAt,
  ];
}
