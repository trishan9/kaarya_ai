import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/features/inbox/data/services/inbox_remote_service.dart';
import 'package:kaarya/features/inbox/presentation/state/inbox_state.dart';
import 'package:kaarya/features/inbox/presentation/view_model/inbox_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockInboxRemoteService extends Mock implements InboxRemoteService {}

void main() {
  late MockInboxRemoteService mockRemoteService;
  late ProviderContainer container;

  setUp(() {
    mockRemoteService = MockInboxRemoteService();
    container = ProviderContainer(
      overrides: [
        inboxRemoteServiceProvider.overrideWithValue(mockRemoteService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'InboxViewModel should initialize ready state when chat is configured',
    () async {
      const payload = InboxBootstrapPayload(
        chatEnabled: true,
        videoEnabled: false,
        apiKey: 'stream-key',
        token: 'token',
      );
      when(
        () => mockRemoteService.fetchBootstrapPayload(),
      ).thenAnswer((_) async => payload);

      final viewModel = container.read(inboxViewModelProvider.notifier);
      await viewModel.initialize();

      final state = container.read(inboxViewModelProvider);
      expect(state.status, InboxLoadStatus.ready);
      expect(state.bootstrap, payload);
      expect(state.errorMessage, isNull);
    },
  );

  test(
    'InboxViewModel should expose configuration error when chat is disabled',
    () async {
      const payload = InboxBootstrapPayload(
        chatEnabled: false,
        videoEnabled: false,
        apiKey: 'stream-key',
        token: 'token',
      );
      when(
        () => mockRemoteService.fetchBootstrapPayload(),
      ).thenAnswer((_) async => payload);

      final viewModel = container.read(inboxViewModelProvider.notifier);
      await viewModel.initialize();

      final state = container.read(inboxViewModelProvider);
      expect(state.status, InboxLoadStatus.error);
      expect(state.bootstrap, payload);
      expect(state.errorMessage, contains('not configured'));
    },
  );

  test('InboxViewModel should expose missing api key error', () async {
    const payload = InboxBootstrapPayload(
      chatEnabled: true,
      videoEnabled: false,
      apiKey: '',
      token: 'token',
    );
    when(
      () => mockRemoteService.fetchBootstrapPayload(),
    ).thenAnswer((_) async => payload);

    final viewModel = container.read(inboxViewModelProvider.notifier);
    await viewModel.initialize();

    final state = container.read(inboxViewModelProvider);
    expect(state.status, InboxLoadStatus.error);
    expect(state.errorMessage, contains('Missing Stream API key'));
  });

  test('InboxViewModel should surface thrown exception message', () async {
    when(
      () => mockRemoteService.fetchBootstrapPayload(),
    ).thenThrow(Exception('Server unavailable'));

    final viewModel = container.read(inboxViewModelProvider.notifier);
    await viewModel.initialize();

    final state = container.read(inboxViewModelProvider);
    expect(state.status, InboxLoadStatus.error);
    expect(state.errorMessage, 'Server unavailable');
  });

  test(
    'InboxViewModel should skip reload when state is already ready',
    () async {
      const payload = InboxBootstrapPayload(
        chatEnabled: true,
        videoEnabled: false,
        apiKey: 'stream-key',
        token: 'token',
      );
      when(
        () => mockRemoteService.fetchBootstrapPayload(),
      ).thenAnswer((_) async => payload);

      final viewModel = container.read(inboxViewModelProvider.notifier);
      await viewModel.initialize();
      await viewModel.initialize();

      verify(() => mockRemoteService.fetchBootstrapPayload()).called(1);
    },
  );
}
