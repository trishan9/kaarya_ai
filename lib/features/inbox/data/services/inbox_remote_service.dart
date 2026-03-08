import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/features/inbox/presentation/state/inbox_state.dart';

final inboxRemoteServiceProvider = Provider<InboxRemoteService>((ref) {
  return InboxRemoteService(apiClient: ref.read(apiClientProvider));
});

class InboxRemoteService {
  InboxRemoteService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<InboxBootstrapPayload> fetchBootstrapPayload() async {
    final configResponse = await _apiClient.get(ApiEndpoints.streamConfig);
    final config = _extractDataMap(configResponse.data);

    final chatEnabled = _asBool(config['chatEnabled']);
    final videoEnabled = _asBool(config['videoEnabled']);
    final configApiKey = _asString(config['chatApiKey']);
    final configVideoApiKey = _asString(config['videoApiKey']);

    if (!chatEnabled) {
      return InboxBootstrapPayload(
        chatEnabled: false,
        videoEnabled: videoEnabled,
        apiKey: configApiKey,
        videoApiKey: configVideoApiKey,
      );
    }

    final tokenResponse = await _apiClient.post(
      ApiEndpoints.streamChatToken,
      data: const <String, dynamic>{},
    );
    final tokenData = _extractDataMap(tokenResponse.data);
    final token = _asString(tokenData['token']);
    final tokenApiKey = _asString(tokenData['apiKey']);

    if (token == null || token.isEmpty) {
      throw const FormatException('Stream chat token was not returned.');
    }

    await _apiClient.post(
      ApiEndpoints.streamEnsureChannels,
      data: const <String, dynamic>{},
    );

    return InboxBootstrapPayload(
      chatEnabled: true,
      videoEnabled: videoEnabled,
      apiKey: tokenApiKey ?? configApiKey,
      videoApiKey: configVideoApiKey,
      token: token,
    );
  }

  Map<String, dynamic> _extractDataMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return raw;
    }
    if (raw is Response && raw.data is Map<String, dynamic>) {
      return _extractDataMap(raw.data);
    }
    throw const FormatException('Unexpected inbox response format.');
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}
