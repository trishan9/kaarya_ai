import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/interviews/data/datasources/interview_datasource.dart';
import 'package:kaarya/features/interviews/data/models/interview_hive_model.dart';

final interviewLocalDatasourceProvider = Provider<IInterviewLocalDataSource>((
  ref,
) {
  final hiveService = ref.read(hiveServiceProvider);
  return InterviewLocalDatasource(hiveService: hiveService);
});

class InterviewLocalDatasource implements IInterviewLocalDataSource {
  final HiveService _hiveService;

  InterviewLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveInterviewsSection(InterviewsSectionHiveModel data) async {
    await _hiveService.saveInterviewsSection(data);
  }

  @override
  Future<InterviewsSectionHiveModel?> getInterviewsSection() async {
    return _hiveService.getInterviewsSection();
  }
}
