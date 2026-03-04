import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/bookmarks/data/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/domain/repositories/bookmark_repository.dart';

final saveInterviewBookmarkUseCaseProvider =
    Provider<SaveInterviewBookmarkUseCase>((ref) {
      return SaveInterviewBookmarkUseCase(
        repository: ref.read(bookmarkRepositoryProvider),
      );
    });

class SaveInterviewBookmarkUseCase implements UseCaseWithParams<bool, String> {
  final IBookmarkRepository _repository;

  SaveInterviewBookmarkUseCase({required IBookmarkRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(String interviewId) {
    return _repository.saveInterviewBookmark(interviewId);
  }
}
