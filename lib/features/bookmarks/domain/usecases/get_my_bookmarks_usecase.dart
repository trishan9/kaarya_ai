import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/bookmarks/data/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:kaarya/features/bookmarks/domain/repositories/bookmark_repository.dart';

final getMyBookmarksUseCaseProvider = Provider<GetMyBookmarksUseCase>((ref) {
  return GetMyBookmarksUseCase(
    repository: ref.read(bookmarkRepositoryProvider),
  );
});

class GetMyBookmarksParams {
  final String? type;
  final String? search;
  final String? sortBy;
  final int? page;
  final int? size;

  const GetMyBookmarksParams({
    this.type,
    this.search,
    this.sortBy,
    this.page,
    this.size,
  });
}

class GetMyBookmarksUseCase
    implements UseCaseWithParams<BookmarksListEntity, GetMyBookmarksParams> {
  final IBookmarkRepository _repository;

  GetMyBookmarksUseCase({required IBookmarkRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, BookmarksListEntity>> call(
    GetMyBookmarksParams params,
  ) {
    return _repository.getMyBookmarks(
      type: params.type,
      search: params.search,
      sortBy: params.sortBy,
      page: params.page,
      size: params.size,
    );
  }
}
