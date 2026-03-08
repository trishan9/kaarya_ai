import 'package:kaarya/features/colleges/data/models/college_api_model.dart';
import 'package:kaarya/features/colleges/data/models/college_hive_model.dart';

abstract interface class ICollegeRemoteDataSource {
  Future<List<CollegeApiModel>> listColleges({
    int page,
    int size,
    String? search,
  });

  Future<CollegeApiModel> getCollegeById(String collegeId);

  Future<CollegeApiModel> createCollege({
    required String name,
    required String institutionType,
    required String location,
    String? logoPath,
  });

  Future<CollegeApiModel> updateCollege({
    required String collegeId,
    String? name,
    String? institutionType,
    String? location,
    String? logoPath,
  });

  Future<bool> deleteCollege(String collegeId);

  Future<CollegeApiModel> joinByCode(String inviteCode);

  Future<String> resetInviteCode(String collegeId);

  Future<List<StudentMemberApiModel>> listStudents({
    required String collegeId,
    int page,
    int size,
  });

  Future<bool> inviteStudent({
    required String collegeId,
    required String email,
    String? program,
    int? year,
  });

  Future<bool> removeStudent({
    required String collegeId,
    required String studentId,
  });

  Future<List<CollegeWorkspaceApiModel>> listCollegeWorkspaces({
    int page,
    int size,
  });

  Future<CollegeMetricsApiModel> getCollegeMetrics(String collegeId);
}

abstract interface class ICollegeLocalDataSource {
  Future<void> saveColleges(List<CollegeHiveModel> data);
  Future<List<CollegeHiveModel>> listColleges();

  Future<void> saveCollege(CollegeHiveModel data);
  Future<CollegeHiveModel?> getCollegeById(String collegeId);

  Future<void> clearAll();
}
