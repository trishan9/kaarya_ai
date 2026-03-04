import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/jobs/data/datasources/job_datasource.dart';
import 'package:kaarya/features/jobs/data/models/job_hive_model.dart';

final jobLocalDatasourceProvider = Provider<IJobLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return JobLocalDatasource(hiveService: hiveService);
});

class JobLocalDatasource implements IJobLocalDataSource {
  final HiveService _hiveService;

  JobLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveJobsSection(JobsSectionHiveModel data) async {
    await _hiveService.saveJobsSection(data);
  }

  @override
  Future<JobsSectionHiveModel?> getJobsSection() async {
    return _hiveService.getJobsSection();
  }
}
