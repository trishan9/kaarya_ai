import 'package:equatable/equatable.dart';

class CandidateProfileEntity extends Equatable {
  final String? headline;
  final String? phone;
  final String? location;
  final String? summary;
  final List<CandidateExperienceEntity> experience;
  final List<CandidateEducationEntity> education;
  final List<CandidateSkillEntity> skills;
  final List<CandidateCertificationEntity> certifications;
  final CandidateSalaryExpectationEntity? salaryExpectation;
  final List<String> preferredRoles;
  final List<String> preferredLocations;
  final List<String> preferredWorkModes;
  final String? defaultResumeId;
  final bool openToWork;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final List<String> portfolioLinks;

  const CandidateProfileEntity({
    this.headline,
    this.phone,
    this.location,
    this.summary,
    this.experience = const [],
    this.education = const [],
    this.skills = const [],
    this.certifications = const [],
    this.salaryExpectation,
    this.preferredRoles = const [],
    this.preferredLocations = const [],
    this.preferredWorkModes = const [],
    this.defaultResumeId,
    this.openToWork = true,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.portfolioLinks = const [],
  });

  @override
  List<Object?> get props => [
    headline,
    phone,
    location,
    summary,
    experience,
    education,
    skills,
    certifications,
    salaryExpectation,
    preferredRoles,
    preferredLocations,
    preferredWorkModes,
    defaultResumeId,
    openToWork,
    linkedinUrl,
    githubUrl,
    portfolioUrl,
    portfolioLinks,
  ];
}

class CandidateExperienceEntity extends Equatable {
  final String? id;
  final String? company;
  final String? title;
  final String? location;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;
  final String? employmentType;

  const CandidateExperienceEntity({
    this.id,
    this.company,
    this.title,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
    this.employmentType,
  });

  @override
  List<Object?> get props => [id, company, title, startDate, endDate];
}

class CandidateEducationEntity extends Equatable {
  final String? id;
  final String? institution;
  final String? degree;
  final String? fieldOfStudy;
  final String? startDate;
  final String? endDate;
  final String? grade;
  final String? description;

  const CandidateEducationEntity({
    this.id,
    this.institution,
    this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.grade,
    this.description,
  });

  @override
  List<Object?> get props => [id, institution, degree, fieldOfStudy];
}

class CandidateSkillEntity extends Equatable {
  final String? id;
  final String name;
  final String category;
  final String proficiency;

  const CandidateSkillEntity({
    this.id,
    required this.name,
    this.category = 'Technical',
    required this.proficiency,
  });

  @override
  List<Object?> get props => [id, name, category, proficiency];
}

class CandidateCertificationEntity extends Equatable {
  final String? id;
  final String? name;
  final String? issuingOrganization;
  final String? issueDate;
  final String? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? mediaUrl;
  final String? mediaMimeType;
  final bool noExpiry;

  const CandidateCertificationEntity({
    this.id,
    this.name,
    this.issuingOrganization,
    this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.mediaUrl,
    this.mediaMimeType,
    this.noExpiry = false,
  });

  @override
  List<Object?> get props => [id, name, issuingOrganization];
}

class CandidateSalaryExpectationEntity extends Equatable {
  final double? min;
  final double? max;
  final String? currency;
  final String? period;
  final bool isNegotiable;

  const CandidateSalaryExpectationEntity({
    this.min,
    this.max,
    this.currency,
    this.period,
    this.isNegotiable = false,
  });

  @override
  List<Object?> get props => [min, max, currency, period, isNegotiable];
}
