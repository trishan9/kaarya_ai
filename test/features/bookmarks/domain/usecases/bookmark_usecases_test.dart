import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/bookmarks/data/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/get_my_bookmarks_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/save_interview_bookmark_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/save_job_bookmark_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/unsave_interview_bookmark_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/unsave_job_bookmark_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockBookmarkRepository extends Mock implements IBookmarkRepository {}

void main() {
  late MockBookmarkRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockBookmarkRepository();
    container = ProviderContainer(
      overrides: [bookmarkRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('bookmark usecase providers should resolve', () {
    expect(
      container.read(getMyBookmarksUseCaseProvider),
      isA<GetMyBookmarksUseCase>(),
    );
    expect(
      container.read(saveJobBookmarkUseCaseProvider),
      isA<SaveJobBookmarkUseCase>(),
    );
    expect(
      container.read(saveInterviewBookmarkUseCaseProvider),
      isA<SaveInterviewBookmarkUseCase>(),
    );
    expect(
      container.read(unsaveJobBookmarkUseCaseProvider),
      isA<UnsaveJobBookmarkUseCase>(),
    );
    expect(
      container.read(unsaveInterviewBookmarkUseCaseProvider),
      isA<UnsaveInterviewBookmarkUseCase>(),
    );
  });

  test('GetMyBookmarksUseCase should pass filters to repository', () async {
    final expected = buildBookmarksListEntity();
    when(
      () => mockRepository.getMyBookmarks(
        type: any(named: 'type'),
        search: any(named: 'search'),
        sortBy: any(named: 'sortBy'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetMyBookmarksUseCase(repository: mockRepository);
    final result = await usecase(
      const GetMyBookmarksParams(
        type: 'job',
        search: 'flutter',
        sortBy: 'saved_at_desc',
        page: 1,
        size: 10,
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.getMyBookmarks(
        type: 'job',
        search: 'flutter',
        sortBy: 'saved_at_desc',
        page: 1,
        size: 10,
      ),
    ).called(1);
  });

  test('SaveJobBookmarkUseCase should call repository', () async {
    when(
      () => mockRepository.saveJobBookmark(any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = SaveJobBookmarkUseCase(repository: mockRepository);
    final result = await usecase('job-1');

    expect(result, const Right(true));
    verify(() => mockRepository.saveJobBookmark('job-1')).called(1);
  });

  test('UnsaveJobBookmarkUseCase should call repository', () async {
    when(
      () => mockRepository.unsaveJobBookmark(any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = UnsaveJobBookmarkUseCase(repository: mockRepository);
    final result = await usecase('job-1');

    expect(result, const Right(true));
    verify(() => mockRepository.unsaveJobBookmark('job-1')).called(1);
  });

  test('SaveInterviewBookmarkUseCase should call repository', () async {
    when(
      () => mockRepository.saveInterviewBookmark(any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = SaveInterviewBookmarkUseCase(repository: mockRepository);
    final result = await usecase('interview-1');

    expect(result, const Right(true));
    verify(() => mockRepository.saveInterviewBookmark('interview-1')).called(1);
  });

  test(
    'UnsaveInterviewBookmarkUseCase should return repository failure',
    () async {
      const failure = ApiFailure(message: 'Unable to unsave');
      when(
        () => mockRepository.unsaveInterviewBookmark(any()),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = UnsaveInterviewBookmarkUseCase(
        repository: mockRepository,
      );
      final result = await usecase('interview-1');

      expect(result, const Left(failure));
    },
  );
}
