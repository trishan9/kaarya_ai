import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:kaarya/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:kaarya/features/leaderboard/presentation/view_model/leaderboard_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockLeaderboardRepository extends Mock
    implements ILeaderboardRepository {}

void main() {
  late MockLeaderboardRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockLeaderboardRepository();
    container = ProviderContainer(
      overrides: [
        leaderboardRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('should load leaderboard successfully', () async {
    final leaderboard = buildLeaderboardEntity();
    when(
      () => mockRepository.getLeaderboard(
        scope: any(named: 'scope'),
        collegeId: any(named: 'collegeId'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(leaderboard));

    final viewModel = container.read(leaderboardViewModelProvider.notifier);
    await viewModel.loadLeaderboard(scope: 'global');

    final state = container.read(leaderboardViewModelProvider);
    expect(state.isLoading, isFalse);
    expect(state.leaderboard, leaderboard);
  });

  test('should clear error', () {
    final viewModel = container.read(leaderboardViewModelProvider.notifier);
    viewModel.state = viewModel.state.copyWith(error: 'Error');

    viewModel.clearError();

    expect(container.read(leaderboardViewModelProvider).error, isNull);
  });

  test('should update scope when switching scope', () async {
    when(
      () => mockRepository.getLeaderboard(
        scope: any(named: 'scope'),
        collegeId: any(named: 'collegeId'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(buildLeaderboardEntity()));

    final viewModel = container.read(leaderboardViewModelProvider.notifier);
    viewModel.switchScope('college');
    await Future<void>.delayed(Duration.zero);

    expect(container.read(leaderboardViewModelProvider).scope, 'college');
  });

  test('should set error when repository fails', () async {
    const failure = ApiFailure(message: 'Leaderboard failed');
    when(
      () => mockRepository.getLeaderboard(
        scope: any(named: 'scope'),
        collegeId: any(named: 'collegeId'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final viewModel = container.read(leaderboardViewModelProvider.notifier);
    await viewModel.loadLeaderboard();

    expect(
      container.read(leaderboardViewModelProvider).error,
      'Leaderboard failed',
    );
  });
}
