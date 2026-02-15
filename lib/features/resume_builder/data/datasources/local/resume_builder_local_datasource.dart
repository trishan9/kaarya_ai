import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/resume_builder/data/datasources/resume_builder_datasource.dart';
import 'package:kaarya/features/resume_builder/data/models/resume_draft_hive_model.dart';

final resumeBuilderLocalDatasourceProvider =
    Provider<IResumeBuilderLocalDataSource>((ref) {
      return ResumeBuilderLocalDataSource(
        hiveService: ref.read(hiveServiceProvider),
      );
    });

class ResumeBuilderLocalDataSource implements IResumeBuilderLocalDataSource {
  final HiveService _hiveService;

  ResumeBuilderLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveDraftsList(List<ResumeDraftHiveModel> data) async {
    await _hiveService.saveDraftsList(data);
  }

  @override
  Future<List<ResumeDraftHiveModel>> listDrafts() async {
    return _hiveService.listDrafts();
  }

  @override
  Future<void> saveDraft(ResumeDraftHiveModel data) async {
    await _hiveService.saveDraft(data);
  }

  @override
  Future<ResumeDraftHiveModel?> getDraftById(String draftId) async {
    return _hiveService.getDraftById(draftId);
  }

  @override
  Future<void> deleteDraft(String draftId) async {
    await _hiveService.deleteDraft(draftId);
  }
}
