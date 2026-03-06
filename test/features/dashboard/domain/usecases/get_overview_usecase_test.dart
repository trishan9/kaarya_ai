import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:kaarya/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:kaarya/features/dashboard/domain/usecases/get_overview_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockDashboardRepository extends Mock implements IDashboardRepository {}

void main() {
  late MockDashboardRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockDashboardRepository();
    container = ProviderContainer(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('overview usecase provider should resolve', () {
    expect(container.read(getOverviewUseCaseProvider), isA<GetOverviewUseCase>());
  });

  test('GetOverviewUseCase should pass month key to repository', () async {
    final expected = buildDashboardOverviewEntity();
    when(
      () => mockRepository.getOverviewData(monthKey: any(named: 'monthKey')),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetOverviewUseCase(dashboardRepository: mockRepository);
    final result = await usecase(const GetOverviewUseCaseParams(monthKey: '2026-03'));

    expect(result, Right(expected));
    verify(
      () => mockRepository.getOverviewData(monthKey: '2026-03'),
    ).called(1);
  });
}
