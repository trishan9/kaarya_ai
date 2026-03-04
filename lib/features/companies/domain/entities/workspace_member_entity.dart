import 'package:equatable/equatable.dart';

class WorkspaceMemberEntity extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? photo;
  final String designation;
  final String joinedAt;

  const WorkspaceMemberEntity({
    required this.userId,
    required this.name,
    required this.email,
    this.photo,
    required this.designation,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    photo,
    designation,
    joinedAt,
  ];
}
