import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/bookmarks/data/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:kaarya/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:kaarya/features/bookmarks/presentation/state/bookmark_state.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';

final bookmarkViewModelProvider =
    NotifierProvider<BookmarkViewModel, BookmarkState>(
      () => BookmarkViewModel(),
    );

class BookmarkViewModel extends Notifier<BookmarkState> {
  @override
  BookmarkState build() => BookmarkState.initial();

  IBookmarkRepository get _repo => ref.read(bookmarkRepositoryProvider);

  Future<void> loadBookmarks({
    String? type,
    String? search,
    String? sortBy,
    int? page,
    int? size,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repo.getMyBookmarks(
      type: type,
      search: search,
      sortBy: sortBy,
      page: page,
      size: size,
    );
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (bookmarks) =>
          state = state.copyWith(isLoading: false, bookmarks: bookmarks),
    );
  }

  Future<bool?> saveJobBookmark(String jobId) async {
    final result = await _repo.saveJobBookmark(jobId);
    return result.fold((_) => null, (ok) => ok);
  }

  Future<bool?> unsaveJobBookmark(String jobId) async {
    final result = await _repo.unsaveJobBookmark(jobId);
    return result.fold((_) => null, (ok) => ok);
  }

  Future<bool?> saveInterviewBookmark(String interviewId) async {
    final result = await _repo.saveInterviewBookmark(interviewId);
    return result.fold((_) => null, (ok) => ok);
  }

  Future<bool?> unsaveInterviewBookmark(String interviewId) async {
    final result = await _repo.unsaveInterviewBookmark(interviewId);
    return result.fold((_) => null, (ok) => ok);
  }

  /// Optimistically remove item from list without refetching.
  void removeJobFromBookmarks(String jobId) {
    final b = state.bookmarks;
    if (b == null) return;
    final newJobs = b.jobs.where((j) => j.id != jobId).toList();
    state = state.copyWith(
      bookmarks: BookmarksListEntity(
        jobs: newJobs,
        interviews: b.interviews,
        totalSaved: b.totalSaved - 1,
        bookmarkedJobs: b.bookmarkedJobs - 1,
        savedInterviews: b.savedInterviews,
      ),
    );
  }

  void removeInterviewFromBookmarks(String interviewId) {
    final b = state.bookmarks;
    if (b == null) return;
    final newInterviews = b.interviews.where((i) => i.id != interviewId).toList();
    state = state.copyWith(
      bookmarks: BookmarksListEntity(
        jobs: b.jobs,
        interviews: newInterviews,
        totalSaved: b.totalSaved - 1,
        bookmarkedJobs: b.bookmarkedJobs,
        savedInterviews: b.savedInterviews - 1,
      ),
    );
  }

  void addJobBackToBookmarks(JobEntity job) {
    final b = state.bookmarks;
    if (b == null) return;
    final newJobs = [...b.jobs, job]..sort((a, c) => c.createdAt.compareTo(a.createdAt));
    state = state.copyWith(
      bookmarks: BookmarksListEntity(
        jobs: newJobs,
        interviews: b.interviews,
        totalSaved: b.totalSaved + 1,
        bookmarkedJobs: b.bookmarkedJobs + 1,
        savedInterviews: b.savedInterviews,
      ),
    );
  }

  void addInterviewBackToBookmarks(InterviewEntity interview) {
    final b = state.bookmarks;
    if (b == null) return;
    final newInterviews = [...b.interviews, interview];
    state = state.copyWith(
      bookmarks: BookmarksListEntity(
        jobs: b.jobs,
        interviews: newInterviews,
        totalSaved: b.totalSaved + 1,
        bookmarkedJobs: b.bookmarkedJobs,
        savedInterviews: b.savedInterviews + 1,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
