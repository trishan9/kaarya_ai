import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/dashboard/data/models/dashboard_api_models.dart';

part 'dashboard_overview_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.dashboardOverviewHiveTypeId)
class DashboardOverviewHiveModel extends HiveObject {
  @HiveField(0)
  final String monthKey;

  @HiveField(1)
  final String json;

  DashboardOverviewHiveModel({required this.monthKey, required this.json});

  factory DashboardOverviewHiveModel.fromApiModel(
    DashboardOverviewApiModel model, {
    String monthKey = 'default',
  }) => DashboardOverviewHiveModel(
    monthKey: monthKey,
    json: jsonEncode(model.toJson()),
  );

  DashboardOverviewApiModel toApiModel() {
    final decoded = jsonDecode(json);
    return DashboardOverviewApiModel.fromJson(
      (decoded as Map).map((k, v) => MapEntry(k.toString(), v)),
    );
  }
}
