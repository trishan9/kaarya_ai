import 'package:kaarya/core/utils/json_parse_helpers.dart';

class ProfilePreferencesApiModel {
  final String? defaultResumeId;
  final List<String> portfolioLinks;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;

  const ProfilePreferencesApiModel({
    this.defaultResumeId,
    this.portfolioLinks = const [],
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
  });

  factory ProfilePreferencesApiModel.fromUserJson(Map<String, dynamic> user) {
    final profile = user['candidateProfile'];
    final p = (profile is Map)
        ? jsonCastMap(profile)
        : const <String, dynamic>{};

    return ProfilePreferencesApiModel(
      defaultResumeId: jsonNullableString(p['defaultResumeId']),
      portfolioLinks: jsonStringList(p['portfolioLinks']),
      linkedinUrl: jsonNullableString(p['linkedinUrl']),
      githubUrl: jsonNullableString(p['githubUrl']),
      portfolioUrl: jsonNullableString(p['portfolioUrl']),
    );
  }
}
