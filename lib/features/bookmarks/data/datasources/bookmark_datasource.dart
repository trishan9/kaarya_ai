import 'package:kaarya/features/bookmarks/data/models/bookmark_hive_model.dart';
import 'package:kaarya/features/bookmarks/data/models/bookmarks_api_model.dart';

abstract interface class IBookmarkRemoteDataSource {
  Future<BookmarksApiModel> getMyBookmarks({
    String? type,
    String? search,
    String? sortBy,
    int? page,
    int? size,
  });

  Future<bool> saveJobBookmark(String jobId);
  Future<bool> unsaveJobBookmark(String jobId);
  Future<bool> saveInterviewBookmark(String interviewId);
  Future<bool> unsaveInterviewBookmark(String interviewId);
}

abstract interface class IBookmarkLocalDataSource {
  Future<void> saveMyBookmarks(BookmarksHiveModel data);
  Future<BookmarksHiveModel?> getMyBookmarks();
}
