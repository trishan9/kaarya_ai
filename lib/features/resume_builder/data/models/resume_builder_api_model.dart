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
    // The backend may return sections data under 'sections', 'content', or at the top level
    final sections = jsonAsMap(json['sections']) ?? const <String, dynamic>{};
    final content = jsonAsMap(json['content']) ?? const <String, dynamic>{};
    // Also check personalInfo inside content (web schema)
    final personalInfoRaw =
        jsonAsMap(json['personalInfo']) ??
        jsonAsMap(content['personalInfo']) ??
        const <String, dynamic>{};
    return ResumeDraftApiModel(
      id: jsonString(json['_id'] ?? json['id']),
      title: jsonString(json['title']),
      template: jsonString(
        json['template'] ?? json['templateId'],
        fallback: 'default',
      ),
      personalInfo: ResumePersonalInfoApiModel.fromApiResponse(personalInfoRaw),
      education: jsonAsList(
        sections['education'] ??
            content['education'] ??
            json['education'],
      ).map((e) => ResumeEducationApiModel.fromApiResponse(jsonCastMap(e))).toList(),
      experience: jsonAsList(
        sections['experience'] ??
            content['experience'] ??
            json['experience'],
      ).map((e) => ResumeExperienceApiModel.fromApiResponse(jsonCastMap(e))).toList(),
      skills: jsonAsList(
        sections['skills'] ?? content['skills'] ?? json['skills'],
      ).map((e) => ResumeSkillApiModel.fromDynamic(e)).toList(),
      projects: jsonAsList(
        sections['projects'] ?? content['projects'] ?? json['projects'],
      ).map((e) => ResumeProjectApiModel.fromApiResponse(jsonCastMap(e))).toList(),
      certifications: jsonAsList(
        sections['certifications'] ??
            content['certifications'] ??
            json['certifications'],
      ).map((e) => ResumeCertificationApiModel.fromApiResponse(jsonCastMap(e))).toList(),
      achievements: jsonAsList(
        sections['achievements'] ??
            content['achievements'] ??
            json['achievements'],
      ).map((e) => ResumeAchievementApiModel.fromApiResponse(jsonCastMap(e))).toList(),
      professionalSummary: jsonString(
        sections['professionalSummary'] ??
            content['professionalSummary'] ??
            json['professionalSummary'],
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

  factory ResumePersonalInfoApiModel.fromApiResponse(Map<String, dynamic> json) {
    // Handle both old schema (name, location, linkedinUrl) and
    // web schema (firstName+lastName, city+country, linkedin)
    final name = jsonString(json['name']).isNotEmpty
        ? jsonString(json['name'])
        : [
              jsonNullableString(json['firstName']) ?? '',
              jsonNullableString(json['lastName']) ?? '',
            ]
                .where((s) => s.isNotEmpty)
                .join(' ')
                .trim();
    final location = jsonString(json['location']).isNotEmpty
        ? jsonString(json['location'])
        : [
              jsonNullableString(json['city']) ?? '',
              jsonNullableString(json['country']) ?? '',
            ]
                .where((s) => s.isNotEmpty)
                .join(', ')
                .trim();
    return ResumePersonalInfoApiModel(
      name: name,
      email: jsonString(json['email']),
      phone: jsonString(json['phone']),
      location: location,
      linkedinUrl:
          jsonNullableString(json['linkedinUrl']) ??
          jsonNullableString(json['linkedin']),
      githubUrl:
          jsonNullableString(json['githubUrl']) ??
          jsonNullableString(json['github']),
      portfolioUrl:
          jsonNullableString(json['portfolioUrl']) ??
          jsonNullableString(json['portfolio']),
    );
  }

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

  factory ResumeEducationApiModel.fromApiResponse(Map<String, dynamic> json) {
    return ResumeEducationApiModel(
      // Handle both "institution" (old) and "school" (web schema)
      institution:
          jsonString(json['institution']).isNotEmpty
              ? jsonString(json['institution'])
              : jsonString(json['school']),
      degree: jsonString(json['degree']),
      // Handle both "fieldOfStudy" (old) and "major" (web schema)
      fieldOfStudy:
          jsonString(json['fieldOfStudy']).isNotEmpty
              ? jsonString(json['fieldOfStudy'])
              : jsonString(json['major']),
      startDate: jsonString(json['startDate']),
      endDate: jsonString(json['endDate']),
      gpa: jsonNullableString(json['gpa']),
      // Handle both "description" (old) and "coursework" (web schema)
      description:
          jsonNullableString(json['description']) ??
          jsonNullableString(json['coursework']),
    );
  }

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

  factory ResumeExperienceApiModel.fromApiResponse(Map<String, dynamic> json) {
    return ResumeExperienceApiModel(
      company: jsonString(json['company']),
      // Handle both "jobTitle" (old) and "position" (web schema)
      jobTitle:
          jsonString(json['jobTitle']).isNotEmpty
              ? jsonString(json['jobTitle'])
              : jsonString(json['position']),
      startDate: jsonString(json['startDate']),
      endDate: jsonString(json['endDate']),
      // Handle both "isCurrent" (old) and "currentlyWorking" (web schema)
      isCurrent:
          jsonBool(json['isCurrent']) || jsonBool(json['currentlyWorking']),
      description: jsonNullableString(json['description']),
      // Handle both "bullets" (old) and "bulletPoints" (web schema)
      bullets:
          jsonStringList(json['bullets']).isNotEmpty
              ? jsonStringList(json['bullets'])
              : jsonStringList(json['bulletPoints']),
    );
  }

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

  factory ResumeSkillApiModel.fromApiResponse(Map<String, dynamic> json) {
    return ResumeSkillApiModel(
      name: jsonString(json['name']),
      category: jsonNullableString(json['category']),
      proficiency: jsonNullableString(json['proficiency']),
    );
  }

  /// Handles both string (web schema: skills as string[]) and map formats.
  static ResumeSkillApiModel fromDynamic(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return ResumeSkillApiModel(name: value);
    }
    if (value is Map) {
      return ResumeSkillApiModel.fromApiResponse(jsonCastMap(value));
    }
    return const ResumeSkillApiModel(name: '');
  }

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

  factory ResumeProjectApiModel.fromApiResponse(Map<String, dynamic> json) {
    return ResumeProjectApiModel(
      name: jsonString(json['name']),
      description: jsonNullableString(json['description']),
      url: jsonNullableString(json['url']),
      technologies: jsonStringList(json['technologies']),
    );
  }

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

  factory ResumeCertificationApiModel.fromApiResponse(Map<String, dynamic> json) {
    return ResumeCertificationApiModel(
      name: jsonString(json['name']),
      issuer: jsonString(json['issuer']),
      issueDate: jsonNullableString(json['issueDate']),
      expiryDate: jsonNullableString(json['expiryDate']),
      credentialUrl: jsonNullableString(json['credentialUrl']),
    );
  }

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

  factory ResumeAchievementApiModel.fromApiResponse(Map<String, dynamic> json) {
    return ResumeAchievementApiModel(
      title: jsonString(json['title']),
      description: jsonNullableString(json['description']),
      date: jsonNullableString(json['date']),
    );
  }

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

// ─── ATS Scan Models ──────────────────────────────────────────────────────────
// Not annotated with @JsonSerializable — uses manual fromApiResponse only.

class AtsScanTipApiModel {
  final String type;
  final String tip;
  final String? explanation;

  const AtsScanTipApiModel({
    required this.type,
    required this.tip,
    this.explanation,
  });

  factory AtsScanTipApiModel.fromApiResponse(Map<String, dynamic> json) {
    return AtsScanTipApiModel(
      type: jsonString(json['type']),
      tip: jsonString(json['tip']),
      explanation: jsonNullableString(json['explanation']),
    );
  }

  AtsScanTipEntity toEntity() =>
      AtsScanTipEntity(type: type, tip: tip, explanation: explanation);
}

class AtsScanCategoryApiModel {
  final double score;
  final List<AtsScanTipApiModel> tips;

  const AtsScanCategoryApiModel({required this.score, required this.tips});

  factory AtsScanCategoryApiModel.fromApiResponse(Map<String, dynamic> json) {
    return AtsScanCategoryApiModel(
      score: jsonDouble(json['score']),
      tips: jsonAsList(json['tips'])
          .map((t) => AtsScanTipApiModel.fromApiResponse(jsonCastMap(t)))
          .toList(),
    );
  }

  AtsScanCategoryEntity toEntity() => AtsScanCategoryEntity(
    score: score,
    tips: tips.map((t) => t.toEntity()).toList(),
  );
}

class AtsScanResultApiModel {
  final double overallScore;
  final String? documentType;
  final String? classificationReason;
  final AtsScanCategoryApiModel? ats;
  final AtsScanCategoryApiModel? toneAndStyle;
  final AtsScanCategoryApiModel? content;
  final AtsScanCategoryApiModel? structure;
  final AtsScanCategoryApiModel? skills;

  const AtsScanResultApiModel({
    required this.overallScore,
    this.documentType,
    this.classificationReason,
    this.ats,
    this.toneAndStyle,
    this.content,
    this.structure,
    this.skills,
  });

  factory AtsScanResultApiModel.fromApiResponse(Map<String, dynamic> json) {
    AtsScanCategoryApiModel? parseCategory(dynamic value) {
      final map = value is Map ? jsonCastMap(value) : null;
      if (map == null) return null;
      return AtsScanCategoryApiModel.fromApiResponse(map);
    }

    return AtsScanResultApiModel(
      overallScore: jsonDouble(json['overallScore']),
      documentType: jsonNullableString(json['documentType']),
      classificationReason: jsonNullableString(json['classificationReason']),
      ats: parseCategory(json['ATS']),
      toneAndStyle: parseCategory(json['toneAndStyle']),
      content: parseCategory(json['content']),
      structure: parseCategory(json['structure']),
      skills: parseCategory(json['skills']),
    );
  }

  AtsScanResultEntity toEntity() {
    return AtsScanResultEntity(
      overallScore: overallScore,
      documentType: documentType,
      classificationReason: classificationReason,
      ats: ats?.toEntity(),
      toneAndStyle: toneAndStyle?.toEntity(),
      content: content?.toEntity(),
      structure: structure?.toEntity(),
      skills: skills?.toEntity(),
    );
  }
}
