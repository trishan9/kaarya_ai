import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/bookmarks/data/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/domain/repositories/bookmark_repository.dart';

final unsaveJobBookmarkUseCaseProvider = Provider<UnsaveJobBookmarkUseCase>((
  ref,
) {
  return UnsaveJobBookmarkUseCase(
    repository: ref.read(bookmarkRepositoryProvider),
  );
});

class UnsaveJobBookmarkUseCase implements UseCaseWithParams<bool, String> {
  final IBookmarkRepository _repository;

  UnsaveJobBookmarkUseCase({required IBookmarkRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(String jobId) {
    return _repository.unsaveJobBookmark(jobId);
  }
}
