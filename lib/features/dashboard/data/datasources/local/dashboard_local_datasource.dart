import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:kaarya/features/dashboard/data/models/dashboard_overview_hive_model.dart';

final dashboardLocalDatasourceProvider = Provider<IDashboardLocalDataSource>((
  ref,
) {
  final hiveService = ref.read(hiveServiceProvider);
  return DashboardLocalDatasource(hiveService: hiveService);
});

class DashboardLocalDatasource implements IDashboardLocalDataSource {
  final HiveService _hiveService;

  DashboardLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveOverviewData(DashboardOverviewHiveModel data) async {
    await _hiveService.saveOverviewData(data);
  }

  @override
  Future<DashboardOverviewHiveModel?> getOverviewData({
    String? monthKey,
  }) async {
    final key = (monthKey ?? '').trim();
    return _hiveService.getOverviewData(key.isEmpty ? 'default' : key);
  }
}
