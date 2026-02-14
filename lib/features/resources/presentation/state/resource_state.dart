import 'package:equatable/equatable.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';

enum ResourceLoadStatus { initial, loading, loaded, error }

class ResourceState extends Equatable {
  static const Object _unset = Object();

  final ResourceLoadStatus coursesListStatus;
  final ResourceLoadStatus courseDetailStatus;
  final ResourceLoadStatus createCourseStatus;
  final ResourceLoadStatus updateCourseStatus;
  final ResourceLoadStatus deleteCourseStatus;

  final ResourceCoursesListEntity? coursesListData;
  final ResourceCourseEntity? courseDetailData;

  final String? coursesListErrorMessage;
  final String? courseDetailErrorMessage;
  final String? createCourseErrorMessage;
  final String? updateCourseErrorMessage;
  final String? deleteCourseErrorMessage;

  final String searchQuery;
  final String? selectedDifficulty;
  final String? selectedCategory;
  final int currentPage;
  final int pageSize;

  const ResourceState({
    this.coursesListStatus = ResourceLoadStatus.initial,
    this.courseDetailStatus = ResourceLoadStatus.initial,
    this.createCourseStatus = ResourceLoadStatus.initial,
    this.updateCourseStatus = ResourceLoadStatus.initial,
    this.deleteCourseStatus = ResourceLoadStatus.initial,
    this.coursesListData,
    this.courseDetailData,
    this.coursesListErrorMessage,
    this.courseDetailErrorMessage,
    this.createCourseErrorMessage,
    this.updateCourseErrorMessage,
    this.deleteCourseErrorMessage,
    this.searchQuery = '',
    this.selectedDifficulty,
    this.selectedCategory,
    this.currentPage = 1,
    this.pageSize = 20,
  });

  ResourceState copyWith({
    ResourceLoadStatus? coursesListStatus,
    ResourceLoadStatus? courseDetailStatus,
    ResourceLoadStatus? createCourseStatus,
    ResourceLoadStatus? updateCourseStatus,
    ResourceLoadStatus? deleteCourseStatus,
    Object? coursesListData = _unset,
    Object? courseDetailData = _unset,
    Object? coursesListErrorMessage = _unset,
    Object? courseDetailErrorMessage = _unset,
    Object? createCourseErrorMessage = _unset,
    Object? updateCourseErrorMessage = _unset,
    Object? deleteCourseErrorMessage = _unset,
    String? searchQuery,
    Object? selectedDifficulty = _unset,
    Object? selectedCategory = _unset,
    int? currentPage,
    int? pageSize,
  }) {
    return ResourceState(
      coursesListStatus: coursesListStatus ?? this.coursesListStatus,
      courseDetailStatus: courseDetailStatus ?? this.courseDetailStatus,
      createCourseStatus: createCourseStatus ?? this.createCourseStatus,
      updateCourseStatus: updateCourseStatus ?? this.updateCourseStatus,
      deleteCourseStatus: deleteCourseStatus ?? this.deleteCourseStatus,
      coursesListData: coursesListData == _unset
          ? this.coursesListData
          : coursesListData as ResourceCoursesListEntity?,
      courseDetailData: courseDetailData == _unset
          ? this.courseDetailData
          : courseDetailData as ResourceCourseEntity?,
      coursesListErrorMessage: coursesListErrorMessage == _unset
          ? this.coursesListErrorMessage
          : coursesListErrorMessage as String?,
      courseDetailErrorMessage: courseDetailErrorMessage == _unset
          ? this.courseDetailErrorMessage
          : courseDetailErrorMessage as String?,
      createCourseErrorMessage: createCourseErrorMessage == _unset
          ? this.createCourseErrorMessage
          : createCourseErrorMessage as String?,
      updateCourseErrorMessage: updateCourseErrorMessage == _unset
          ? this.updateCourseErrorMessage
          : updateCourseErrorMessage as String?,
      deleteCourseErrorMessage: deleteCourseErrorMessage == _unset
          ? this.deleteCourseErrorMessage
          : deleteCourseErrorMessage as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDifficulty: selectedDifficulty == _unset
          ? this.selectedDifficulty
          : selectedDifficulty as String?,
      selectedCategory: selectedCategory == _unset
          ? this.selectedCategory
          : selectedCategory as String?,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
    coursesListStatus,
    courseDetailStatus,
    createCourseStatus,
    updateCourseStatus,
    deleteCourseStatus,
    coursesListData,
    courseDetailData,
    coursesListErrorMessage,
    courseDetailErrorMessage,
    createCourseErrorMessage,
    updateCourseErrorMessage,
    deleteCourseErrorMessage,
    searchQuery,
    selectedDifficulty,
    selectedCategory,
    currentPage,
    pageSize,
  ];
}
