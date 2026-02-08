import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/companies/data/models/company_api_model.dart';

part 'company_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.companyHiveTypeId)
class CompanyHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String industry;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final String? logo;

  @HiveField(5)
  final String verifiedStatus;

  @HiveField(6)
  final String? inviteCode;

  @HiveField(7)
  final int recruitersCount;

  @HiveField(8)
  final String createdAt;

  CompanyHiveModel({
    required this.id,
    required this.name,
    required this.industry,
    required this.location,
    this.logo,
    required this.verifiedStatus,
    this.inviteCode,
    required this.recruitersCount,
    required this.createdAt,
  });

  factory CompanyHiveModel.fromApiModel(CompanyApiModel model) =>
      CompanyHiveModel(
        id: model.id,
        name: model.name,
        industry: model.industry,
        location: model.location,
        logo: model.logo,
        verifiedStatus: model.verifiedStatus,
        inviteCode: model.inviteCode,
        recruitersCount: model.recruitersCount,
        createdAt: model.createdAt,
      );

  CompanyApiModel toApiModel() => CompanyApiModel(
    id: id,
    name: name,
    industry: industry,
    location: location,
    logo: logo,
    verifiedStatus: verifiedStatus,
    inviteCode: inviteCode,
    recruitersCount: recruitersCount,
    createdAt: createdAt,
  );
}
