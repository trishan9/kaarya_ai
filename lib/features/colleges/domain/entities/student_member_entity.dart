import 'package:equatable/equatable.dart';

class StudentMemberEntity extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? photo;
  final String joinedAt;

  const StudentMemberEntity({
    required this.userId,
    required this.name,
    required this.email,
    this.photo,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [userId, name, email, photo, joinedAt];
}
