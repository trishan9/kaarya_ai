import 'package:kaarya/features/resources/data/models/resource_course_api_model.dart';
import 'package:kaarya/features/resources/data/models/resource_course_hive_model.dart';

abstract interface class IResourceRemoteDataSource {
  Future<ResourceCoursesListApiResponse> listCourses({
    int page,
    int size,
    String? search,
    String? difficulty,
    String? category,
  });

  Future<ResourceCourseApiModel> getCourseById(String courseId);

  Future<ResourceCourseApiModel> createCourse({
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
  });

  Future<ResourceCourseApiModel> updateCourse({
    required String courseId,
    required Map<String, dynamic> fields,
  });

  Future<bool> deleteCourse(String courseId);
}

abstract interface class IResourceLocalDataSource {
  Future<void> saveCoursesList(List<ResourceCourseHiveModel> data);
  Future<List<ResourceCourseHiveModel>> listCourses();

  Future<void> saveCourse(ResourceCourseHiveModel data);
  Future<ResourceCourseHiveModel?> getCourseById(String courseId);
}

class ResourceCoursesListApiResponse {
  final List<ResourceCourseApiModel> courses;
  final int totalCount;
  final int page;
  final int size;

  const ResourceCoursesListApiResponse({
    required this.courses,
    required this.totalCount,
    required this.page,
    required this.size,
  });

  factory ResourceCoursesListApiResponse.fromJson(Map<String, dynamic> json) {
    return ResourceCoursesListApiResponse(
      courses: ResourceCourseApiModel.fromApiList(json['resources']),
      totalCount: json['totalCount'] is int ? json['totalCount'] as int : 0,
      page: json['page'] is int ? json['page'] as int : 1,
      size: json['size'] is int ? json['size'] as int : 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resources': courses.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'size': size,
    };
  }
}
