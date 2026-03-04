import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  final String id;
  final String name;
  final String industry;
  final String location;
  final String? logo;
  final String verifiedStatus;
  final String? inviteCode;
  final int recruitersCount;
  final String createdAt;

  const CompanyEntity({
    required this.id,
    required this.name,
    required this.industry,
    required this.location,
    this.logo,
    required this.verifiedStatus,
    this.inviteCode,
    required this.recruitersCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    industry,
    location,
    logo,
    verifiedStatus,
    inviteCode,
    recruitersCount,
    createdAt,
  ];
}
