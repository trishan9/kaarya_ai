import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/inbox/data/services/inbox_remote_service.dart';
import 'package:kaarya/features/inbox/presentation/state/inbox_state.dart';

final inboxViewModelProvider = NotifierProvider<InboxViewModel, InboxState>(
  InboxViewModel.new,
);

class InboxViewModel extends Notifier<InboxState> {
  late final InboxRemoteService _remoteService;

  @override
  InboxState build() {
    _remoteService = ref.read(inboxRemoteServiceProvider);
    return const InboxState();
  }

  Future<void> initialize({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        state.status == InboxLoadStatus.ready &&
        state.bootstrap != null) {
      return;
    }

    state = state.copyWith(status: InboxLoadStatus.loading, clearError: true);

    try {
      final payload = await _remoteService.fetchBootstrapPayload();
      if (!payload.chatEnabled) {
        state = state.copyWith(
          status: InboxLoadStatus.error,
          bootstrap: payload,
          errorMessage:
              'Inbox is unavailable right now. Chat is not configured on the server.',
        );
        return;
      }

      if (payload.apiKey == null || payload.apiKey!.isEmpty) {
        state = state.copyWith(
          status: InboxLoadStatus.error,
          bootstrap: payload,
          errorMessage:
              'Inbox is unavailable right now. Missing Stream API key.',
        );
        return;
      }

      state = state.copyWith(
        status: InboxLoadStatus.ready,
        bootstrap: payload,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: InboxLoadStatus.error,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
