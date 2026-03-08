import 'package:equatable/equatable.dart';

class OAuthProviderStatusEntity extends Equatable {
  const OAuthProviderStatusEntity({
    required this.provider,
    required this.enabled,
    required this.mobileStrategy,
    this.serverClientId,
  });

  final String provider;
  final bool enabled;
  final String mobileStrategy;
  final String? serverClientId;

  @override
  List<Object?> get props => [
    provider,
    enabled,
    mobileStrategy,
    serverClientId,
  ];
}
