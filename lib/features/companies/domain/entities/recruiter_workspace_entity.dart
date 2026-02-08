import 'package:equatable/equatable.dart';

class RecruiterWorkspaceEntity extends Equatable {
  final String companyId;
  final String companyName;
  final String? companyLogo;
  final String designation;
  final String joinedAt;

  const RecruiterWorkspaceEntity({
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    required this.designation,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
    companyId,
    companyName,
    companyLogo,
    designation,
    joinedAt,
  ];
}
