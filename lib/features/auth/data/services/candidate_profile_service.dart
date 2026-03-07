import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/auth/domain/entities/candidate_profile_entity.dart';

/// User info from /auth/me for prefill (name, email, photo).
class CurrentUserData {
  const CurrentUserData({this.name, this.email, this.photo});

  final String? name;
  final String? email;
  final String? photo;
}

final candidateProfileServiceProvider = Provider<CandidateProfileService>((
  ref,
) {
  return CandidateProfileService(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

/// Raw response from /auth/me - single fetch, shared by both providers.
/// Invalidate this (e.g. after profile update) to refresh user + candidate profile.
final authMeResponseProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final service = ref.read(candidateProfileServiceProvider);
  return service.fetchAuthMeResponse();
});

/// User name, email, photo from /auth/me for form prefill.
final currentUserProvider = FutureProvider<CurrentUserData?>((ref) async {
  final response = await ref.watch(authMeResponseProvider.future);
  if (response == null) return null;
  final userData = response['userData'] as Map<String, dynamic>?;
  if (userData == null) return null;
  return CurrentUserData(
    name: jsonNullableString(userData['name']),
    email: jsonNullableString(userData['email']),
    photo: jsonNullableString(userData['photo']),
  );
});

/// Fetches candidate profile from /auth/me. Uses shared fetch to avoid duplicate API calls.
final candidateProfileProvider = FutureProvider<CandidateProfileEntity?>((
  ref,
) async {
  final response = await ref.watch(authMeResponseProvider.future);
  if (response == null) return null;
  return _parseCandidateProfileFromResponse(response);
});

class CandidateProfileService {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  CandidateProfileService({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  /// Fetches /auth/me and returns parsed user + profile data for providers.
  Future<Map<String, dynamic>?> fetchAuthMeResponse() async {
    if (!_userSessionService.isLoggedIn()) return null;

    try {
      final response = await _apiClient.get(ApiEndpoints.me);
      final respData = response.data;
      if (respData is! Map || respData['success'] != true) return null;

      final data = respData['data'];
      if (data is! Map) return null;
      final dataMap = Map<String, dynamic>.from(data);

      // Backend returns data = user object directly (user + linkedAccounts + linkedProviders)
      final userData = dataMap['user'];
      final userMap = userData is Map<String, dynamic>
          ? userData
          : (userData is Map ? Map<String, dynamic>.from(userData) : dataMap);
      return {'userData': userMap};
    } catch (_) {
      return null;
    }
  }

  Future<CandidateProfileEntity?> fetchCandidateProfile() async {
    final raw = await fetchAuthMeResponse();
    if (raw == null) return null;
    return _parseCandidateProfileFromResponse(raw);
  }
}

CandidateProfileEntity _parseCandidateProfileFromResponse(
  Map<String, dynamic> response,
) {
  final userData = response['userData'] as Map<String, dynamic>?;
  if (userData == null) return const CandidateProfileEntity();

  final profile = userData['candidateProfile'];
  final p = switch (profile) {
    Map() => jsonCastMap(profile),
    String() => _parseProfileString(profile),
    _ => <String, dynamic>{},
  };

  final experience = _parseExperience(p['experience']);
  final education = _parseEducation(p['education']);
  final skills = _parseSkills(p['skills']);
  final certifications = _parseCertifications(p['certifications']);
  final salary = _parseSalary(p['salary']);
  final preferredRoles = jsonStringList(p['preferredRoles']);
  final preferredLocations = jsonStringList(p['preferredLocations']);
  final preferredWorkModes = jsonStringList(p['preferredWorkModes']);

  return CandidateProfileEntity(
    headline: jsonNullableString(p['headline']),
    phone: jsonNullableString(p['phone']),
    location: jsonNullableString(p['location']),
    summary: jsonNullableString(p['summary']),
    experience: experience,
    education: education,
    skills: skills,
    certifications: certifications,
    salaryExpectation: salary,
    preferredRoles: preferredRoles,
    preferredLocations: preferredLocations,
    preferredWorkModes: preferredWorkModes,
    defaultResumeId: jsonNullableString(p['defaultResumeId']),
    openToWork: jsonBool(p['openToWork'], fallback: true),
    linkedinUrl: jsonNullableString(p['linkedinUrl']),
    githubUrl: jsonNullableString(p['githubUrl']),
    portfolioUrl: jsonNullableString(p['portfolioUrl']),
    portfolioLinks: jsonStringList(p['portfolioLinks']),
  );
}

/// Backend uses jobTitle, companyName. Also supports title, company for compatibility.
List<CandidateExperienceEntity> _parseExperience(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) {
    final m = item is Map ? jsonCastMap(item) : <String, dynamic>{};
    return CandidateExperienceEntity(
      id: jsonNullableString(m['id']),
      company:
          jsonNullableString(m['companyName']) ??
          jsonNullableString(m['company']),
      title:
          jsonNullableString(m['jobTitle']) ?? jsonNullableString(m['title']),
      location: jsonNullableString(m['location']),
      startDate: _normalizeDateString(m['startDate']),
      endDate: _normalizeDateString(m['endDate']),
      isCurrent: jsonBool(
        m['currentlyWorking'],
        fallback: jsonBool(m['isCurrent']),
      ),
      description: jsonNullableString(m['description']),
      employmentType: jsonNullableString(m['employmentType']),
    );
  }).toList();
}

/// Normalizes date from backend (YYYY-MM, YYYY-MM-DD, or ISO string) to YYYY-MM or YYYY-MM-DD.
String? _normalizeDateString(dynamic value) {
  final s = jsonNullableString(value);
  if (s == null || s.isEmpty) return null;
  if (RegExp(r'^\d{4}-\d{2}(-\d{2})?$').hasMatch(s)) return s;
  final iso = RegExp(r'^(\d{4}-\d{2}-\d{2})');
  final match = iso.firstMatch(s);
  return match != null ? match.group(1) : s;
}

List<CandidateEducationEntity> _parseEducation(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) {
    final m = item is Map ? jsonCastMap(item) : <String, dynamic>{};
    return CandidateEducationEntity(
      id: jsonNullableString(m['id']),
      institution: jsonNullableString(m['institution']),
      degree: jsonNullableString(m['degree']),
      fieldOfStudy: jsonNullableString(m['fieldOfStudy']),
      startDate: _normalizeDateString(m['startDate']),
      endDate: _normalizeDateString(m['endDate']),
      grade: jsonNullableString(m['grade']),
      description: jsonNullableString(m['description']),
    );
  }).toList();
}

List<CandidateSkillEntity> _parseSkills(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) {
        if (item is String && item.trim().isNotEmpty) {
          return CandidateSkillEntity(name: item.trim(), proficiency: '');
        }
        final m = item is Map ? jsonCastMap(item) : <String, dynamic>{};
        final name = jsonNullableString(m['name']) ?? jsonString(m['name']);
        if (name.isEmpty) return null;
        return CandidateSkillEntity(
          id: jsonNullableString(m['id']),
          name: name,
          category: jsonString(m['category'], fallback: 'Technical'),
          proficiency: jsonString(m['proficiency']),
        );
      })
      .whereType<CandidateSkillEntity>()
      .toList();
}

/// Backend uses issuer (not issuingOrganization).
List<CandidateCertificationEntity> _parseCertifications(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) {
    final m = item is Map ? jsonCastMap(item) : <String, dynamic>{};
    return CandidateCertificationEntity(
      id: jsonNullableString(m['id']),
      name: jsonNullableString(m['name']),
      issuingOrganization:
          jsonNullableString(m['issuer']) ??
          jsonNullableString(m['issuingOrganization']),
      issueDate: _normalizeDateString(m['issueDate']),
      expiryDate: _normalizeDateString(m['expiryDate']),
      credentialId:
          jsonNullableString(m['credentialId']) ??
          jsonNullableString(m['credential_id']),
      credentialUrl: jsonNullableString(m['credentialUrl']),
      mediaUrl: jsonNullableString(m['mediaUrl']),
      mediaMimeType: jsonNullableString(m['mediaMimeType']),
      noExpiry: jsonBool(m['noExpiry']),
    );
  }).toList();
}

CandidateSalaryExpectationEntity? _parseSalary(dynamic value) {
  if (value == null) return null;
  final m = value is Map ? jsonCastMap(value) : <String, dynamic>{};
  final min = jsonDoubleOrNull(m['minAmount']) ?? jsonDoubleOrNull(m['min']);
  final max = jsonDoubleOrNull(m['maxAmount']) ?? jsonDoubleOrNull(m['max']);
  if (min == null && max == null && jsonNullableString(m['currency']) == null) {
    return null;
  }
  return CandidateSalaryExpectationEntity(
    min: min,
    max: max,
    currency: jsonNullableString(m['currency']),
    period: jsonNullableString(m['period']),
    isNegotiable: jsonBool(m['isNegotiable']),
  );
}

Map<String, dynamic> _parseProfileString(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return <String, dynamic>{};
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is Map) {
      return jsonCastMap(decoded);
    }
  } catch (_) {}
  return <String, dynamic>{};
}
