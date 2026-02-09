import 'package:kaarya/features/dashboard/data/models/dashboard_api_models.dart';
import 'package:kaarya/features/dashboard/data/models/dashboard_overview_hive_model.dart';
import 'package:kaarya/features/dashboard/data/models/extra_api_models.dart';

abstract interface class IDashboardRemoteDataSource {
  Future<DashboardOverviewApiModel> getOverviewData({String? monthKey});
  Future<ProfilePreferencesApiModel> getProfilePreferences();
}

abstract interface class IDashboardLocalDataSource {
  Future<void> saveOverviewData(DashboardOverviewHiveModel data);
  Future<DashboardOverviewHiveModel?> getOverviewData({String? monthKey});
}
