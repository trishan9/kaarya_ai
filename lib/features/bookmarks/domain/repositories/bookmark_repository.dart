import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/bookmarks/domain/entities/bookmark_entity.dart';

abstract interface class IBookmarkRepository {
  Future<Either<Failure, BookmarksListEntity>> getMyBookmarks({
    String? type,
    String? search,
    String? sortBy,
    int? page,
    int? size,
  });

  Future<Either<Failure, bool>> saveJobBookmark(String jobId);
  Future<Either<Failure, bool>> unsaveJobBookmark(String jobId);
  Future<Either<Failure, bool>> saveInterviewBookmark(String interviewId);
  Future<Either<Failure, bool>> unsaveInterviewBookmark(String interviewId);
}
