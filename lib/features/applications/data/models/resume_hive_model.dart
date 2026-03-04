import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/applications/data/models/application_api_model.dart';

part 'resume_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.resumeHiveTypeId)
class ResumeHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fileName;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String uploadedAt;

  @HiveField(4)
  final double? atsScore;

  ResumeHiveModel({
    required this.id,
    required this.fileName,
    required this.url,
    required this.uploadedAt,
    this.atsScore,
  });

  factory ResumeHiveModel.fromApiModel(ResumeApiModel model) => ResumeHiveModel(
    id: model.id,
    fileName: model.fileName,
    url: model.url,
    uploadedAt: model.uploadedAt,
    atsScore: model.atsScore,
  );

  ResumeApiModel toApiModel() => ResumeApiModel(
    id: id,
    fileName: fileName,
    url: url,
    uploadedAt: uploadedAt,
    atsScore: atsScore,
  );
}
