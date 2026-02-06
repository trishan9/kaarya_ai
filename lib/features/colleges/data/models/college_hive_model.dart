import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/colleges/data/models/college_api_model.dart';

part 'college_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.collegeHiveTypeId)
class CollegeHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String institutionType;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final String? logo;

  @HiveField(5)
  final String? inviteCode;

  @HiveField(6)
  final int studentsCount;

  @HiveField(7)
  final String createdAt;

  CollegeHiveModel({
    required this.id,
    required this.name,
    required this.institutionType,
    required this.location,
    this.logo,
    this.inviteCode,
    required this.studentsCount,
    required this.createdAt,
  });

  factory CollegeHiveModel.fromApiModel(CollegeApiModel model) =>
      CollegeHiveModel(
        id: model.id,
        name: model.name,
        institutionType: model.institutionType,
        location: model.location,
        logo: model.logo,
        inviteCode: model.inviteCode,
        studentsCount: model.studentsCount,
        createdAt: model.createdAt,
      );

  CollegeApiModel toApiModel() => CollegeApiModel(
    id: id,
    name: name,
    institutionType: institutionType,
    location: location,
    logo: logo,
    inviteCode: inviteCode,
    studentsCount: studentsCount,
    createdAt: createdAt,
  );
}
