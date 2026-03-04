import 'package:kaarya/features/bookmarks/domain/entities/bookmark_entity.dart';

class BookmarkState {
  final bool isLoading;
  final String? error;
  final BookmarksListEntity? bookmarks;

  const BookmarkState({this.isLoading = false, this.error, this.bookmarks});

  factory BookmarkState.initial() => const BookmarkState();

  BookmarkState copyWith({
    bool? isLoading,
    String? error,
    BookmarksListEntity? bookmarks,
    bool clearError = false,
  }) => BookmarkState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    bookmarks: bookmarks ?? this.bookmarks,
  );
}
