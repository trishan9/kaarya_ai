import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/resources/data/datasources/resource_datasource.dart';
import 'package:kaarya/features/resources/data/models/resource_course_hive_model.dart';

final resourceLocalDatasourceProvider = Provider<IResourceLocalDataSource>((
  ref,
) {
  return ResourceLocalDataSource(hiveService: ref.read(hiveServiceProvider));
});

class ResourceLocalDataSource implements IResourceLocalDataSource {
  final HiveService _hiveService;

  ResourceLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveCoursesList(List<ResourceCourseHiveModel> data) async {
    await _hiveService.saveCoursesList(data);
  }

  @override
  Future<List<ResourceCourseHiveModel>> listCourses() async {
    return _hiveService.listCourses();
  }

  @override
  Future<void> saveCourse(ResourceCourseHiveModel data) async {
    await _hiveService.saveCourse(data);
  }

  @override
  Future<ResourceCourseHiveModel?> getCourseById(String courseId) async {
    return _hiveService.getCourseById(courseId);
  }
}
