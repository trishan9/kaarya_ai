import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/bookmarks/data/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/domain/repositories/bookmark_repository.dart';

final unsaveInterviewBookmarkUseCaseProvider =
    Provider<UnsaveInterviewBookmarkUseCase>((ref) {
      return UnsaveInterviewBookmarkUseCase(
        repository: ref.read(bookmarkRepositoryProvider),
      );
    });

class UnsaveInterviewBookmarkUseCase
    implements UseCaseWithParams<bool, String> {
  final IBookmarkRepository _repository;

  UnsaveInterviewBookmarkUseCase({required IBookmarkRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(String interviewId) {
    return _repository.unsaveInterviewBookmark(interviewId);
  }
}
