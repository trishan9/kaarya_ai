import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/resume_builder/domain/entities/ats_scan_result_entity.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';

part 'resume_builder_api_model.g.dart';

@JsonSerializable()
class ResumeDraftApiModel {
  final String id;
  final String title;
  final String template;
  final ResumePersonalInfoApiModel personalInfo;
  final List<ResumeEducationApiModel> education;
  final List<ResumeExperienceApiModel> experience;
  final List<ResumeSkillApiModel> skills;
  final List<ResumeProjectApiModel> projects;
  final List<ResumeCertificationApiModel> certifications;
  final List<ResumeAchievementApiModel> achievements;
  final String professionalSummary;
  final String createdAt;
  final String updatedAt;

  const ResumeDraftApiModel({
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

  factory ResumeDraftApiModel.fromApiResponse(Map<String, dynamic> json) {
    final sections = jsonAsMap(json['sections']) ?? const <String, dynamic>{};
    return ResumeDraftApiModel(
      id: jsonString(json['_id'] ?? json['id']),
      title: jsonString(json['title']),
      template: jsonString(json['template'], fallback: 'default'),
      personalInfo: ResumePersonalInfoApiModel.fromJson(
        jsonAsMap(json['personalInfo']) ?? const <String, dynamic>{},
      ),
      education: jsonAsList(
        sections['education'] ?? json['education'],
      ).map((e) => ResumeEducationApiModel.fromJson(e)).toList(),
      experience: jsonAsList(
        sections['experience'] ?? json['experience'],
      ).map((e) => ResumeExperienceApiModel.fromJson(e)).toList(),
      skills: jsonAsList(
        sections['skills'] ?? json['skills'],
      ).map((e) => ResumeSkillApiModel.fromJson(e)).toList(),
      projects: jsonAsList(
        sections['projects'] ?? json['projects'],
      ).map((e) => ResumeProjectApiModel.fromJson(e)).toList(),
      certifications: jsonAsList(
        sections['certifications'] ?? json['certifications'],
      ).map((e) => ResumeCertificationApiModel.fromJson(e)).toList(),
      achievements: jsonAsList(
        sections['achievements'] ?? json['achievements'],
      ).map((e) => ResumeAchievementApiModel.fromJson(e)).toList(),
      professionalSummary: jsonString(
        sections['professionalSummary'] ?? json['professionalSummary'],
      ),
      createdAt: jsonString(json['createdAt']),
      updatedAt: jsonString(json['updatedAt']),
    );
  }

  factory ResumeDraftApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeDraftApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeDraftApiModelToJson(this);

  ResumeDraftEntity toEntity() {
    return ResumeDraftEntity(
      id: id,
      title: title,
      template: template,
      personalInfo: personalInfo.toEntity(),
      education: education.map((e) => e.toEntity()).toList(),
      experience: experience.map((e) => e.toEntity()).toList(),
      skills: skills.map((e) => e.toEntity()).toList(),
      projects: projects.map((e) => e.toEntity()).toList(),
      certifications: certifications.map((e) => e.toEntity()).toList(),
      achievements: achievements.map((e) => e.toEntity()).toList(),
      professionalSummary: professionalSummary,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<ResumeDraftApiModel> fromApiList(dynamic value) {
    if (value is! List) return const <ResumeDraftApiModel>[];
    return value
        .whereType<Map>()
        .map(
          (e) => ResumeDraftApiModel.fromApiResponse(
            e.map((key, val) => MapEntry(key.toString(), val)),
          ),
        )
        .toList();
  }
}

@JsonSerializable()
class ResumePersonalInfoApiModel {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;

  const ResumePersonalInfoApiModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
  });

  factory ResumePersonalInfoApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResumePersonalInfoApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResumePersonalInfoApiModelToJson(this);

  ResumePersonalInfoEntity toEntity() {
    return ResumePersonalInfoEntity(
      name: name,
      email: email,
      phone: phone,
      location: location,
      linkedinUrl: linkedinUrl,
      githubUrl: githubUrl,
      portfolioUrl: portfolioUrl,
    );
  }
}

@JsonSerializable()
class ResumeEducationApiModel {
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String endDate;
  final String? gpa;
  final String? description;

  const ResumeEducationApiModel({
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
    this.gpa,
    this.description,
  });

  factory ResumeEducationApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeEducationApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeEducationApiModelToJson(this);

  ResumeEducationEntity toEntity() {
    return ResumeEducationEntity(
      institution: institution,
      degree: degree,
      fieldOfStudy: fieldOfStudy,
      startDate: startDate,
      endDate: endDate,
      gpa: gpa,
      description: description,
    );
  }
}

@JsonSerializable()
class ResumeExperienceApiModel {
  final String company;
  final String jobTitle;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final String? description;
  final List<String> bullets;

  const ResumeExperienceApiModel({
    required this.company,
    required this.jobTitle,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    this.description,
    required this.bullets,
  });

  factory ResumeExperienceApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeExperienceApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeExperienceApiModelToJson(this);

  ResumeExperienceEntity toEntity() {
    return ResumeExperienceEntity(
      company: company,
      jobTitle: jobTitle,
      startDate: startDate,
      endDate: endDate,
      isCurrent: isCurrent,
      description: description,
      bullets: bullets,
    );
  }
}

@JsonSerializable()
class ResumeSkillApiModel {
  final String name;
  final String? category;
  final String? proficiency;

  const ResumeSkillApiModel({
    required this.name,
    this.category,
    this.proficiency,
  });

  factory ResumeSkillApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeSkillApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeSkillApiModelToJson(this);

  ResumeSkillEntity toEntity() {
    return ResumeSkillEntity(
      name: name,
      category: category,
      proficiency: proficiency,
    );
  }
}

@JsonSerializable()
class ResumeProjectApiModel {
  final String name;
  final String? description;
  final String? url;
  final List<String> technologies;

  const ResumeProjectApiModel({
    required this.name,
    this.description,
    this.url,
    required this.technologies,
  });

  factory ResumeProjectApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeProjectApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeProjectApiModelToJson(this);

  ResumeProjectEntity toEntity() {
    return ResumeProjectEntity(
      name: name,
      description: description,
      url: url,
      technologies: technologies,
    );
  }
}

@JsonSerializable()
class ResumeCertificationApiModel {
  final String name;
  final String issuer;
  final String? issueDate;
  final String? expiryDate;
  final String? credentialUrl;

  const ResumeCertificationApiModel({
    required this.name,
    required this.issuer,
    this.issueDate,
    this.expiryDate,
    this.credentialUrl,
  });

  factory ResumeCertificationApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeCertificationApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeCertificationApiModelToJson(this);

  ResumeCertificationEntity toEntity() {
    return ResumeCertificationEntity(
      name: name,
      issuer: issuer,
      issueDate: issueDate,
      expiryDate: expiryDate,
      credentialUrl: credentialUrl,
    );
  }
}

@JsonSerializable()
class ResumeAchievementApiModel {
  final String title;
  final String? description;
  final String? date;

  const ResumeAchievementApiModel({
    required this.title,
    this.description,
    this.date,
  });

  factory ResumeAchievementApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeAchievementApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeAchievementApiModelToJson(this);

  ResumeAchievementEntity toEntity() {
    return ResumeAchievementEntity(
      title: title,
      description: description,
      date: date,
    );
  }
}

@JsonSerializable()
class AtsScanResultApiModel {
  final double overallScore;
  final double atsScore;
  final double toneStyleScore;
  final double contentScore;
  final double structureScore;
  final double skillsScore;
  final List<String> suggestions;
  final List<String> improvements;

  const AtsScanResultApiModel({
    required this.overallScore,
    required this.atsScore,
    required this.toneStyleScore,
    required this.contentScore,
    required this.structureScore,
    required this.skillsScore,
    required this.suggestions,
    required this.improvements,
  });

  factory AtsScanResultApiModel.fromJson(Map<String, dynamic> json) =>
      _$AtsScanResultApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AtsScanResultApiModelToJson(this);

  AtsScanResultEntity toEntity() {
    return AtsScanResultEntity(
      overallScore: overallScore,
      atsScore: atsScore,
      toneStyleScore: toneStyleScore,
      contentScore: contentScore,
      structureScore: structureScore,
      skillsScore: skillsScore,
      suggestions: suggestions,
      improvements: improvements,
    );
  }
}
