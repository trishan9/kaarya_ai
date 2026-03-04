import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/bookmarks/data/datasources/bookmark_datasource.dart';
import 'package:kaarya/features/bookmarks/data/models/bookmark_hive_model.dart';

final bookmarkLocalDatasourceProvider = Provider<IBookmarkLocalDataSource>((
  ref,
) {
  return BookmarkLocalDataSource(hiveService: ref.read(hiveServiceProvider));
});

class BookmarkLocalDataSource implements IBookmarkLocalDataSource {
  final HiveService _hiveService;

  BookmarkLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveMyBookmarks(BookmarksHiveModel data) async {
    await _hiveService.saveMyBookmarks(data);
  }

  @override
  Future<BookmarksHiveModel?> getMyBookmarks() async {
    return _hiveService.getMyBookmarks();
  }
}
