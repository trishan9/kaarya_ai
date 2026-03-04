import 'package:equatable/equatable.dart';

class ResumeDraftEntity extends Equatable {
  final String id;
  final String title;
  final String template;
  final ResumePersonalInfoEntity personalInfo;
  final List<ResumeEducationEntity> education;
  final List<ResumeExperienceEntity> experience;
  final List<ResumeSkillEntity> skills;
  final List<ResumeProjectEntity> projects;
  final List<ResumeCertificationEntity> certifications;
  final List<ResumeAchievementEntity> achievements;
  final String professionalSummary;
  final String createdAt;
  final String updatedAt;

  const ResumeDraftEntity({
    required this.id,
    required this.title,
    required this.template,
    required this.personalInfo,
    required this.education,
    required this.experience,
    required this.skills,
    required this.projects,
    required this.certifications,
    required this.achievements,
    required this.professionalSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    template,
    personalInfo,
    education,
    experience,
    skills,
    projects,
    certifications,
    achievements,
    professionalSummary,
    createdAt,
    updatedAt,
  ];
}

class ResumePersonalInfoEntity extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;

  const ResumePersonalInfoEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    location,
    linkedinUrl,
    githubUrl,
    portfolioUrl,
  ];
}

class ResumeEducationEntity extends Equatable {
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String endDate;
  final String? gpa;
  final String? description;

  const ResumeEducationEntity({
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
    this.gpa,
    this.description,
  });

  @override
  List<Object?> get props => [
    institution,
    degree,
    fieldOfStudy,
    startDate,
    endDate,
    gpa,
    description,
  ];
}

class ResumeExperienceEntity extends Equatable {
  final String company;
  final String jobTitle;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final String? description;
  final List<String> bullets;

  const ResumeExperienceEntity({
    required this.company,
    required this.jobTitle,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    this.description,
    required this.bullets,
  });

  @override
  List<Object?> get props => [
    company,
    jobTitle,
    startDate,
    endDate,
    isCurrent,
    description,
    bullets,
  ];
}

class ResumeSkillEntity extends Equatable {
  final String name;
  final String? category;
  final String? proficiency;

  const ResumeSkillEntity({
    required this.name,
    this.category,
    this.proficiency,
  });

  @override
  List<Object?> get props => [name, category, proficiency];
}

class ResumeProjectEntity extends Equatable {
  final String name;
  final String? description;
  final String? url;
  final List<String> technologies;

  const ResumeProjectEntity({
    required this.name,
    this.description,
    this.url,
    required this.technologies,
  });

  @override
  List<Object?> get props => [name, description, url, technologies];
}

class ResumeCertificationEntity extends Equatable {
  final String name;
  final String issuer;
  final String? issueDate;
  final String? expiryDate;
  final String? credentialUrl;

  const ResumeCertificationEntity({
    required this.name,
    required this.issuer,
    this.issueDate,
    this.expiryDate,
    this.credentialUrl,
  });

  @override
  List<Object?> get props => [
    name,
    issuer,
    issueDate,
    expiryDate,
    credentialUrl,
  ];
}

class ResumeAchievementEntity extends Equatable {
  final String title;
  final String? description;
  final String? date;

  const ResumeAchievementEntity({
    required this.title,
    this.description,
    this.date,
  });

  @override
  List<Object?> get props => [title, description, date];
}

class ResumeDraftsListEntity extends Equatable {
  final List<ResumeDraftEntity> drafts;
  final int totalCount;
  final int page;
  final int size;

  const ResumeDraftsListEntity({
    required this.drafts,
    required this.totalCount,
    required this.page,
    required this.size,
  });

  @override
  List<Object?> get props => [drafts, totalCount, page, size];
}

class AiSummaryResultEntity extends Equatable {
  final String summary;

  const AiSummaryResultEntity({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class ExperienceBulletsResultEntity extends Equatable {
  final List<String> bullets;

  const ExperienceBulletsResultEntity({required this.bullets});

  @override
  List<Object?> get props => [bullets];
}

class AiSuggestionsResultEntity extends Equatable {
  final List<String> suggestions;

  const AiSuggestionsResultEntity({required this.suggestions});

  @override
  List<Object?> get props => [suggestions];
}

class GeneratePdfResultEntity extends Equatable {
  final String pdfUrl;

  const GeneratePdfResultEntity({required this.pdfUrl});

  @override
  List<Object?> get props => [pdfUrl];
}
