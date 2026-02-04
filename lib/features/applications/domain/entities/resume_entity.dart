import 'package:equatable/equatable.dart';

class ResumeEntity extends Equatable {
  final String id;
  final String fileName;
  final String url;
  final String uploadedAt;
  final double? atsScore;

  const ResumeEntity({
    required this.id,
    required this.fileName,
    required this.url,
    required this.uploadedAt,
    this.atsScore,
  });

  @override
  List<Object?> get props => [id, fileName, url];
}
