import 'package:kaarya/features/auth/domain/entities/oauth_provider_status_entity.dart';

class OAuthProviderStatusApiModel {
  const OAuthProviderStatusApiModel({
    required this.provider,
    required this.enabled,
    required this.mobileStrategy,
    this.serverClientId,
  });

  final String provider;
  final bool enabled;
  final String mobileStrategy;
  final String? serverClientId;

  factory OAuthProviderStatusApiModel.fromJson(Map<String, dynamic> json) {
    return OAuthProviderStatusApiModel(
      provider: (json['provider'] as String? ?? '').trim(),
      enabled: json['enabled'] == true,
      mobileStrategy: (json['mobileStrategy'] as String? ?? '').trim(),
      serverClientId: (json['serverClientId'] as String?)?.trim(),
    );
  }

  OAuthProviderStatusEntity toEntity() {
    return OAuthProviderStatusEntity(
      provider: provider,
      enabled: enabled,
      mobileStrategy: mobileStrategy,
      serverClientId: serverClientId,
    );
  }
}
