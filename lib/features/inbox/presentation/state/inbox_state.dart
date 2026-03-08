class InboxBootstrapPayload {
  const InboxBootstrapPayload({
    required this.chatEnabled,
    required this.videoEnabled,
    this.apiKey,
    this.videoApiKey,
    this.token,
  });

  final bool chatEnabled;
  final bool videoEnabled;
  final String? apiKey;
  final String? videoApiKey;
  final String? token;
}

enum InboxLoadStatus { idle, loading, ready, error }

class InboxState {
  const InboxState({
    this.status = InboxLoadStatus.idle,
    this.bootstrap,
    this.errorMessage,
  });

  final InboxLoadStatus status;
  final InboxBootstrapPayload? bootstrap;
  final String? errorMessage;

  InboxState copyWith({
    InboxLoadStatus? status,
    InboxBootstrapPayload? bootstrap,
    String? errorMessage,
    bool clearBootstrap = false,
    bool clearError = false,
  }) {
    return InboxState(
      status: status ?? this.status,
      bootstrap: clearBootstrap ? null : (bootstrap ?? this.bootstrap),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
