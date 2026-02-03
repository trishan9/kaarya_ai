import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/applications/data/datasources/application_datasource.dart';
import 'package:kaarya/features/applications/data/models/application_hive_model.dart';
import 'package:kaarya/features/applications/data/models/resume_hive_model.dart';

final applicationLocalDatasourceProvider =
    Provider<IApplicationLocalDataSource>((ref) {
      return ApplicationLocalDataSource(
        hiveService: ref.read(hiveServiceProvider),
      );
    });

class ApplicationLocalDataSource implements IApplicationLocalDataSource {
  final HiveService _hiveService;

  ApplicationLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveMyApplications(List<ApplicationHiveModel> data) async {
    await _hiveService.saveMyApplications(data);
  }

  @override
  Future<List<ApplicationHiveModel>> getMyApplications() async {
    return _hiveService.getMyApplications();
  }

  @override
  Future<void> saveResumes(List<ResumeHiveModel> data) async {
    await _hiveService.saveResumes(data);
  }

  @override
  Future<List<ResumeHiveModel>> listMyResumes() async {
    return _hiveService.listMyResumes();
  }
}
