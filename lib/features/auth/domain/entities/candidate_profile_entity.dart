import 'package:equatable/equatable.dart';

class CandidateProfileEntity extends Equatable {
  final List<CandidateExperienceEntity> experience;
  final List<CandidateEducationEntity> education;
  final List<CandidateSkillEntity> skills;
  final List<CandidateCertificationEntity> certifications;
  final CandidateSalaryExpectationEntity? salaryExpectation;
  final String? workMode;
  final List<String> preferredRoles;
  final List<String> preferredLocations;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final List<String> portfolioLinks;

  const CandidateProfileEntity({
    this.experience = const [],
    this.education = const [],
    this.skills = const [],
    this.certifications = const [],
    this.salaryExpectation,
    this.workMode,
    this.preferredRoles = const [],
    this.preferredLocations = const [],
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.portfolioLinks = const [],
  });

  @override
  List<Object?> get props => [
    experience,
    education,
    skills,
    certifications,
    salaryExpectation,
    workMode,
    preferredRoles,
    preferredLocations,
  ];
}

class CandidateExperienceEntity extends Equatable {
  final String? company;
  final String? title;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;

  const CandidateExperienceEntity({
    this.company,
    this.title,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
  });

  @override
  List<Object?> get props => [company, title, startDate, endDate];
}

class CandidateEducationEntity extends Equatable {
  final String? institution;
  final String? degree;
  final String? fieldOfStudy;
  final String? startDate;
  final String? endDate;
  final String? grade;

  const CandidateEducationEntity({
    this.institution,
    this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.grade,
  });

  @override
  List<Object?> get props => [institution, degree, fieldOfStudy];
}

class CandidateSkillEntity extends Equatable {
  final String name;
  final String proficiency;

  const CandidateSkillEntity({required this.name, required this.proficiency});

  @override
  List<Object?> get props => [name, proficiency];
}

class CandidateCertificationEntity extends Equatable {
  final String? name;
  final String? issuingOrganization;
  final String? issueDate;
  final String? expiryDate;
  final String? credentialUrl;
  final String? mediaUrl;

  const CandidateCertificationEntity({
    this.name,
    this.issuingOrganization,
    this.issueDate,
    this.expiryDate,
    this.credentialUrl,
    this.mediaUrl,
  });

  @override
  List<Object?> get props => [name, issuingOrganization];
}

class CandidateSalaryExpectationEntity extends Equatable {
  final double? min;
  final double? max;
  final String? currency;
  final String? period;

  const CandidateSalaryExpectationEntity({
    this.min,
    this.max,
    this.currency,
    this.period,
  });

  @override
  List<Object?> get props => [min, max, currency, period];
}
