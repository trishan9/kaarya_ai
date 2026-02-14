import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';

abstract interface class IResourceRepository {
  Future<Either<Failure, ResourceCoursesListEntity>> listCourses({
    int page,
    int size,
    String? search,
    String? difficulty,
    String? category,
  });

  Future<Either<Failure, ResourceCourseEntity>> getCourseById(String courseId);

  Future<Either<Failure, ResourceCourseEntity>> createCourse({
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

  Future<Either<Failure, ResourceCourseEntity>> updateCourse({
    required String courseId,
    required Map<String, dynamic> fields,
  });

  Future<Either<Failure, bool>> deleteCourse(String courseId);
}
