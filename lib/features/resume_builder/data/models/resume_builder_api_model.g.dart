// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_builder_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResumeDraftApiModel _$ResumeDraftApiModelFromJson(Map<String, dynamic> json) =>
    ResumeDraftApiModel(
      id: json['id'] as String,
      title: json['title'] as String,
      template: json['template'] as String,
      personalInfo: ResumePersonalInfoApiModel.fromJson(
          json['personalInfo'] as Map<String, dynamic>),
      education: (json['education'] as List<dynamic>)
          .map((e) =>
              ResumeEducationApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      experience: (json['experience'] as List<dynamic>)
          .map((e) =>
              ResumeExperienceApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => ResumeSkillApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      projects: (json['projects'] as List<dynamic>)
          .map((e) => ResumeProjectApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      certifications: (json['certifications'] as List<dynamic>)
          .map((e) =>
              ResumeCertificationApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) =>
              ResumeAchievementApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      professionalSummary: json['professionalSummary'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$ResumeDraftApiModelToJson(
        ResumeDraftApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'template': instance.template,
      'personalInfo': instance.personalInfo,
      'education': instance.education,
      'experience': instance.experience,
      'skills': instance.skills,
      'projects': instance.projects,
      'certifications': instance.certifications,
      'achievements': instance.achievements,
      'professionalSummary': instance.professionalSummary,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

ResumePersonalInfoApiModel _$ResumePersonalInfoApiModelFromJson(
        Map<String, dynamic> json) =>
    ResumePersonalInfoApiModel(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      linkedinUrl: json['linkedinUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
      portfolioUrl: json['portfolioUrl'] as String?,
    );

Map<String, dynamic> _$ResumePersonalInfoApiModelToJson(
        ResumePersonalInfoApiModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'location': instance.location,
      'linkedinUrl': instance.linkedinUrl,
      'githubUrl': instance.githubUrl,
      'portfolioUrl': instance.portfolioUrl,
    };

ResumeEducationApiModel _$ResumeEducationApiModelFromJson(
        Map<String, dynamic> json) =>
    ResumeEducationApiModel(
      institution: json['institution'] as String,
      degree: json['degree'] as String,
      fieldOfStudy: json['fieldOfStudy'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      gpa: json['gpa'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ResumeEducationApiModelToJson(
        ResumeEducationApiModel instance) =>
    <String, dynamic>{
      'institution': instance.institution,
      'degree': instance.degree,
      'fieldOfStudy': instance.fieldOfStudy,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'gpa': instance.gpa,
      'description': instance.description,
    };

ResumeExperienceApiModel _$ResumeExperienceApiModelFromJson(
        Map<String, dynamic> json) =>
    ResumeExperienceApiModel(
      company: json['company'] as String,
      jobTitle: json['jobTitle'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      isCurrent: json['isCurrent'] as bool,
      description: json['description'] as String?,
      bullets:
          (json['bullets'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ResumeExperienceApiModelToJson(
        ResumeExperienceApiModel instance) =>
    <String, dynamic>{
      'company': instance.company,
      'jobTitle': instance.jobTitle,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'isCurrent': instance.isCurrent,
      'description': instance.description,
      'bullets': instance.bullets,
    };

ResumeSkillApiModel _$ResumeSkillApiModelFromJson(Map<String, dynamic> json) =>
    ResumeSkillApiModel(
      name: json['name'] as String,
      category: json['category'] as String?,
      proficiency: json['proficiency'] as String?,
    );

Map<String, dynamic> _$ResumeSkillApiModelToJson(
        ResumeSkillApiModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'proficiency': instance.proficiency,
    };

ResumeProjectApiModel _$ResumeProjectApiModelFromJson(
        Map<String, dynamic> json) =>
    ResumeProjectApiModel(
      name: json['name'] as String,
      description: json['description'] as String?,
      url: json['url'] as String?,
      technologies: (json['technologies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ResumeProjectApiModelToJson(
        ResumeProjectApiModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'technologies': instance.technologies,
    };

ResumeCertificationApiModel _$ResumeCertificationApiModelFromJson(
        Map<String, dynamic> json) =>
    ResumeCertificationApiModel(
      name: json['name'] as String,
      issuer: json['issuer'] as String,
      issueDate: json['issueDate'] as String?,
      expiryDate: json['expiryDate'] as String?,
      credentialUrl: json['credentialUrl'] as String?,
    );

Map<String, dynamic> _$ResumeCertificationApiModelToJson(
        ResumeCertificationApiModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'issuer': instance.issuer,
      'issueDate': instance.issueDate,
      'expiryDate': instance.expiryDate,
      'credentialUrl': instance.credentialUrl,
    };

ResumeAchievementApiModel _$ResumeAchievementApiModelFromJson(
        Map<String, dynamic> json) =>
    ResumeAchievementApiModel(
      title: json['title'] as String,
      description: json['description'] as String?,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$ResumeAchievementApiModelToJson(
        ResumeAchievementApiModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'date': instance.date,
    };

AtsScanResultApiModel _$AtsScanResultApiModelFromJson(
        Map<String, dynamic> json) =>
    AtsScanResultApiModel(
      overallScore: (json['overallScore'] as num).toDouble(),
      atsScore: (json['atsScore'] as num).toDouble(),
      toneStyleScore: (json['toneStyleScore'] as num).toDouble(),
      contentScore: (json['contentScore'] as num).toDouble(),
      structureScore: (json['structureScore'] as num).toDouble(),
      skillsScore: (json['skillsScore'] as num).toDouble(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      improvements: (json['improvements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AtsScanResultApiModelToJson(
        AtsScanResultApiModel instance) =>
    <String, dynamic>{
      'overallScore': instance.overallScore,
      'atsScore': instance.atsScore,
      'toneStyleScore': instance.toneStyleScore,
      'contentScore': instance.contentScore,
      'structureScore': instance.structureScore,
      'skillsScore': instance.skillsScore,
      'suggestions': instance.suggestions,
      'improvements': instance.improvements,
    };
