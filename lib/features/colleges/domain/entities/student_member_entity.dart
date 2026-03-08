import 'package:equatable/equatable.dart';

class StudentMemberEntity extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? photo;
  final String? program;
  final int? year;
  final String joinedAt;

  const StudentMemberEntity({
    required this.userId,
    required this.name,
    required this.email,
    this.photo,
    this.program,
    this.year,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    photo,
    program,
    year,
    joinedAt,
  ];
}
