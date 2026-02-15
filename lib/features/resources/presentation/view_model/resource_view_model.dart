import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/resources/domain/usecases/create_course_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/delete_course_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/get_course_by_id_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/list_courses_usecase.dart';
import 'package:kaarya/features/resources/domain/usecases/update_course_usecase.dart';
import 'package:kaarya/features/resources/presentation/state/resource_state.dart';

final resourceViewModelProvider =
    NotifierProvider<ResourceViewModel, ResourceState>(ResourceViewModel.new);

class ResourceViewModel extends Notifier<ResourceState> {
  late final ListCoursesUseCase _listCoursesUseCase;
  late final GetCourseByIdUseCase _getCourseByIdUseCase;
  late final CreateCourseUseCase _createCourseUseCase;
  late final UpdateCourseUseCase _updateCourseUseCase;
  late final DeleteCourseUseCase _deleteCourseUseCase;

  @override
  ResourceState build() {
    _listCoursesUseCase = ref.read(listCoursesUseCaseProvider);
    _getCourseByIdUseCase = ref.read(getCourseByIdUseCaseProvider);
    _createCourseUseCase = ref.read(createCourseUseCaseProvider);
    _updateCourseUseCase = ref.read(updateCourseUseCaseProvider);
    _deleteCourseUseCase = ref.read(deleteCourseUseCaseProvider);
    return const ResourceState();
  }

  void resetState() {
    state = const ResourceState();
  }

  Future<void> loadCourses({
    String? search,
    String? difficulty,
    String? category,
    int? page,
    bool forceRefresh = false,
  }) async {
    final nextSearch = (search ?? state.searchQuery).trim();
    final nextDifficulty = difficulty ?? state.selectedDifficulty;
    final nextCategory = category ?? state.selectedCategory;
    final nextPage = page ?? state.currentPage;

    final queryChanged =
        nextSearch != state.searchQuery ||
        nextDifficulty != state.selectedDifficulty ||
        nextCategory != state.selectedCategory ||
        nextPage != state.currentPage;

    if (!forceRefresh &&
        !queryChanged &&
        state.coursesListStatus == ResourceLoadStatus.loaded &&
        state.coursesListData != null) {
      return;
    }

    state = state.copyWith(
      coursesListStatus: ResourceLoadStatus.loading,
      coursesListErrorMessage: null,
      searchQuery: nextSearch,
      selectedDifficulty: nextDifficulty,
      selectedCategory: nextCategory,
      currentPage: nextPage,
    );

    final result = await _listCoursesUseCase(
      ListCoursesUseCaseParams(
        page: nextPage,
        size: state.pageSize,
        search: nextSearch.isEmpty ? null : nextSearch,
        difficulty: nextDifficulty,
        category: nextCategory,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        coursesListStatus: ResourceLoadStatus.error,
        coursesListErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        coursesListStatus: ResourceLoadStatus.loaded,
        coursesListData: data,
        coursesListErrorMessage: null,
      ),
    );
  }

  Future<void> loadCourseDetail(String courseId) async {
    state = state.copyWith(
      courseDetailStatus: ResourceLoadStatus.loading,
      courseDetailData: null,
      courseDetailErrorMessage: null,
    );

    final result = await _getCourseByIdUseCase(
      GetCourseByIdUseCaseParams(courseId: courseId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        courseDetailStatus: ResourceLoadStatus.error,
        courseDetailErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        courseDetailStatus: ResourceLoadStatus.loaded,
        courseDetailData: data,
        courseDetailErrorMessage: null,
      ),
    );
  }

  Future<Failure?> createCourse({
    required String title,
    String? description,
    required String category,
    required String generationMode,
    required String difficulty,
    required List<String> targetRoles,
    int? chapterCount,
    String? visibility,
    bool? includeVideoRecommendations,
    String? promptContext,
    String? jobDescriptionContext,
  }) async {
    state = state.copyWith(
      createCourseStatus: ResourceLoadStatus.loading,
      createCourseErrorMessage: null,
    );

    final result = await _createCourseUseCase(
      CreateCourseUseCaseParams(
        title: title,
        description: description,
        category: category,
        generationMode: generationMode,
        difficulty: difficulty,
        targetRoles: targetRoles,
        chapterCount: chapterCount,
        visibility: visibility,
        includeVideoRecommendations: includeVideoRecommendations,
        promptContext: promptContext,
        jobDescriptionContext: jobDescriptionContext,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          createCourseStatus: ResourceLoadStatus.error,
          createCourseErrorMessage: failure.message,
        );
        return failure;
      },
      (data) {
        state = state.copyWith(
          createCourseStatus: ResourceLoadStatus.loaded,
          createCourseErrorMessage: null,
        );
        return null;
      },
    );
  }

  Future<Failure?> updateCourse({
    required String courseId,
    required Map<String, dynamic> fields,
  }) async {
    state = state.copyWith(
      updateCourseStatus: ResourceLoadStatus.loading,
      updateCourseErrorMessage: null,
    );

    final result = await _updateCourseUseCase(
      UpdateCourseUseCaseParams(courseId: courseId, fields: fields),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          updateCourseStatus: ResourceLoadStatus.error,
          updateCourseErrorMessage: failure.message,
        );
        return failure;
      },
      (data) {
        state = state.copyWith(
          updateCourseStatus: ResourceLoadStatus.loaded,
          courseDetailData: data,
          updateCourseErrorMessage: null,
        );
        return null;
      },
    );
  }

  Future<Failure?> deleteCourse(String courseId) async {
    state = state.copyWith(
      deleteCourseStatus: ResourceLoadStatus.loading,
      deleteCourseErrorMessage: null,
    );

    final result = await _deleteCourseUseCase(
      DeleteCourseUseCaseParams(courseId: courseId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          deleteCourseStatus: ResourceLoadStatus.error,
          deleteCourseErrorMessage: failure.message,
        );
        return failure;
      },
      (_) {
        state = state.copyWith(
          deleteCourseStatus: ResourceLoadStatus.loaded,
          deleteCourseErrorMessage: null,
        );
        return null;
      },
    );
  }
}
