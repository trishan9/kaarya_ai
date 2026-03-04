import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/colleges/data/datasources/college_datasource.dart';
import 'package:kaarya/features/colleges/data/models/college_hive_model.dart';

final collegeLocalDatasourceProvider = Provider<ICollegeLocalDataSource>((ref) {
  return CollegeLocalDataSource(hiveService: ref.read(hiveServiceProvider));
});

class CollegeLocalDataSource implements ICollegeLocalDataSource {
  final HiveService _hiveService;

  CollegeLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveColleges(List<CollegeHiveModel> data) async {
    await _hiveService.saveColleges(data);
  }

  @override
  Future<List<CollegeHiveModel>> listColleges() async {
    return _hiveService.listColleges();
  }

  @override
  Future<void> saveCollege(CollegeHiveModel data) async {
    await _hiveService.saveCollege(data);
  }

  @override
  Future<CollegeHiveModel?> getCollegeById(String collegeId) async {
    return _hiveService.getCollegeById(collegeId);
  }

  @override
  Future<void> clearAll() async {
    await _hiveService.clearColleges();
  }
}
