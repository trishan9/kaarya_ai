import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:kaarya/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:kaarya/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockLeaderboardRepository extends Mock implements ILeaderboardRepository {}

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

  test('leaderboard usecase provider should resolve', () {
    expect(container.read(getLeaderboardUseCaseProvider), isA<GetLeaderboardUseCase>());
  });

  test('GetLeaderboardUseCase should pass filters to repository', () async {
    final expected = buildLeaderboardEntity();
    when(
      () => mockRepository.getLeaderboard(
        scope: any(named: 'scope'),
        collegeId: any(named: 'collegeId'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetLeaderboardUseCase(repository: mockRepository);
    final result = await usecase(
      const GetLeaderboardParams(
        scope: 'global',
        collegeId: 'college-1',
        page: 1,
        size: 20,
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.getLeaderboard(
        scope: 'global',
        collegeId: 'college-1',
        page: 1,
        size: 20,
      ),
    ).called(1);
  });
}
