import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vapi/vapi.dart';

final vapiInterviewServiceProvider = Provider<VapiInterviewService>((ref) {
  return VapiInterviewService();
});

/// Event types emitted by the VAPI interview service.
enum VapiEventType {
  callStart,
  callEnd,
  transcript,
  partialTranscript, // in-progress speech, updates frequently
  speechStart,
  speechEnd,
  error,
}

class VapiInterviewEvent {
  final VapiEventType type;
  final Map<String, dynamic> data;

  const VapiInterviewEvent({required this.type, this.data = const {}});
}

/// Thin wrapper around the official VAPI Flutter SDK for interview-specific use.
class VapiInterviewService {
  VapiClient? _client;
  VapiCall? _call;
  StreamSubscription? _eventSubscription;
  final _eventController = StreamController<VapiInterviewEvent>.broadcast();
  String? _vapiCallId;

  /// Stream of interview events (call-start, call-end, transcript, etc.)
  Stream<VapiInterviewEvent> get events => _eventController.stream;

  /// The VAPI call ID (available after startCall succeeds).
  String? get vapiCallId => _vapiCallId;

  /// Whether a call is currently active.
  bool get isActive => _call != null;

  /// Initialize VAPI with a web token. Must be called before [startCall].
  void init(String webToken) {
    _client?.dispose();
    _client = VapiClient(webToken);
    _vapiCallId = null;
  }

  /// Start a VAPI call with an assistant config or assistant ID.
  Future<void> startCall({
    Map<String, dynamic>? assistant,
    String? assistantId,
    Map<String, dynamic>? assistantOverrides,
  }) async {
    if (_client == null) {
      _eventController.add(
        const VapiInterviewEvent(
          type: VapiEventType.error,
          data: {'message': 'VAPI not initialized. Call init() first.'},
        ),
      );
      return;
    }

    try {
      final call = await _client!.start(
        assistant: assistant,
        assistantId: assistantId,
        assistantOverrides: assistantOverrides ?? const {},
      );
      _call = call;
      _vapiCallId = call.id;
      _listenToEvents(call);

      _eventController.add(
        VapiInterviewEvent(
          type: VapiEventType.callStart,
          data: {'callId': _vapiCallId},
        ),
      );
    } catch (e) {
      _eventController.add(
        VapiInterviewEvent(
          type: VapiEventType.error,
          data: {'message': e.toString()},
        ),
      );
    }
  }

  /// End the current VAPI call.
  Future<void> endCall() async {
    try {
      await _call?.stop();
    } catch (e) {
      _eventController.add(
        VapiInterviewEvent(
          type: VapiEventType.error,
          data: {'message': e.toString()},
        ),
      );
    }
  }

  /// Clean up resources.
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _call?.dispose();
    _call = null;
    _client?.dispose();
    _client = null;
    _vapiCallId = null;
    _eventController.close();
  }

  void _listenToEvents(VapiCall call) {
    _eventSubscription?.cancel();
    _eventSubscription = call.onEvent.listen((event) {
      final label = event.label;

      switch (label) {
        case 'call-start':
          // Ensure speakerphone is active when the assistant starts listening.
          try {
            _call?.setAudioDevice(device: VapiAudioDevice.speakerphone);
          } catch (_) {}
          break;

        case 'call-end':
          _eventController.add(
            const VapiInterviewEvent(type: VapiEventType.callEnd),
          );
          break;

        case 'message':
          _handleMessage(event.value);
          break;

        case 'error':
          final value = event.value;
          final message = value is Map
              ? (value['error']?.toString() ?? 'Unknown error')
              : value?.toString() ?? 'Unknown error';
          _eventController.add(
            VapiInterviewEvent(
              type: VapiEventType.error,
              data: {'message': message},
            ),
          );
          break;

        case 'speech-start':
          _eventController.add(
            const VapiInterviewEvent(type: VapiEventType.speechStart),
          );
          break;

        case 'speech-end':
          _eventController.add(
            const VapiInterviewEvent(type: VapiEventType.speechEnd),
          );
          break;
      }
    });
  }

  void _handleMessage(dynamic value) {
    if (value is! Map) return;

    final type = value['type']?.toString();
    final transcriptType = value['transcriptType']?.toString();

    // Emit transcript events (both partial for live preview and final for record)
    if (type == 'transcript') {
      final role = value['role']?.toString() ?? 'user';
      final content = value['transcript']?.toString().trim() ?? '';
      if (content.isEmpty) return;

      final normalizedRole = (role == 'assistant' || role == 'system')
          ? role
          : 'user';

      if (transcriptType == 'partial') {
        _eventController.add(
          VapiInterviewEvent(
            type: VapiEventType.partialTranscript,
            data: {'role': normalizedRole, 'content': content},
          ),
        );
        return;
      }

      if (transcriptType == 'final') {
        _eventController.add(
          VapiInterviewEvent(
            type: VapiEventType.transcript,
            data: {
              'role': normalizedRole,
              'content': content,
              'timestamp': DateTime.now().toIso8601String(),
            },
          ),
        );
        return;
      }
    }

    // Speech status updates via messages
    if (type == 'speech-update') {
      final status = value['status']?.toString();
      if (status == 'started') {
        _eventController.add(
          const VapiInterviewEvent(type: VapiEventType.speechStart),
        );
      } else if (status == 'stopped') {
        _eventController.add(
          const VapiInterviewEvent(type: VapiEventType.speechEnd),
        );
      }
    }
  }
}
