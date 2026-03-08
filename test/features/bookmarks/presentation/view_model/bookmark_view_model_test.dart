import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/bookmarks/data/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/presentation/state/bookmark_state.dart';
import 'package:kaarya/features/bookmarks/presentation/view_model/bookmark_view_model.dart';
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

  group('BookmarkViewModel', () {
    test('should load bookmarks successfully', () async {
      final bookmarks = buildBookmarksListEntity();
      when(
        () => mockRepository.getMyBookmarks(
          type: any(named: 'type'),
          search: any(named: 'search'),
          sortBy: any(named: 'sortBy'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => Right(bookmarks));

      final viewModel = container.read(bookmarkViewModelProvider.notifier);
      await viewModel.loadBookmarks(type: 'job');

      final state = container.read(bookmarkViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.bookmarks, bookmarks);
      expect(state.error, isNull);
    });

    test('should expose error when loading fails', () async {
      const failure = ApiFailure(message: 'Load failed');
      when(
        () => mockRepository.getMyBookmarks(
          type: any(named: 'type'),
          search: any(named: 'search'),
          sortBy: any(named: 'sortBy'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(bookmarkViewModelProvider.notifier);
      await viewModel.loadBookmarks();

      expect(container.read(bookmarkViewModelProvider).error, 'Load failed');
    });

    test('should remove and add bookmarks optimistically', () {
      final viewModel = container.read(bookmarkViewModelProvider.notifier);
      viewModel.state = BookmarkState.initial().copyWith(
        bookmarks: buildBookmarksListEntity(),
      );

      viewModel.removeJobFromBookmarks('job-1');
      expect(
        container.read(bookmarkViewModelProvider).bookmarks?.jobs,
        isEmpty,
      );

      viewModel.addJobBackToBookmarks(
        buildJobEntity(id: 'job-1', isSaved: true),
      );
      expect(
        container.read(bookmarkViewModelProvider).bookmarks?.jobs.length,
        1,
      );
    });

    test('should return null for save failure', () async {
      when(
        () => mockRepository.saveJobBookmark(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Save failed')));

      final viewModel = container.read(bookmarkViewModelProvider.notifier);
      final result = await viewModel.saveJobBookmark('job-1');

      expect(result, isNull);
    });

    test('should clear error', () {
      final viewModel = container.read(bookmarkViewModelProvider.notifier);
      viewModel.state = BookmarkState.initial().copyWith(error: 'Error');

      viewModel.clearError();

      expect(container.read(bookmarkViewModelProvider).error, isNull);
    });
  });
}
