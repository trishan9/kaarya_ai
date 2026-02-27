import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_metrics_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_workspace_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/student_member_entity.dart';

abstract interface class ICollegeRepository {
  Future<Either<Failure, List<CollegeEntity>>> listColleges({
    int page,
    int size,
    String? search,
  });

  Future<Either<Failure, CollegeEntity>> getCollegeById(String collegeId);

  Future<Either<Failure, CollegeEntity>> createCollege({
    required String name,
    required String institutionType,
    required String location,
    String? logoPath,
  });

  Future<Either<Failure, CollegeEntity>> updateCollege({
    required String collegeId,
    String? name,
    String? institutionType,
    String? location,
    String? logoPath,
  });

  Future<Either<Failure, bool>> deleteCollege(String collegeId);

  Future<Either<Failure, CollegeEntity>> joinByCode(String inviteCode);

  Future<Either<Failure, String>> resetInviteCode(String collegeId);

  Future<Either<Failure, List<StudentMemberEntity>>> listStudents({
    required String collegeId,
    int page,
    int size,
  });

  Future<Either<Failure, bool>> inviteStudent({
    required String collegeId,
    required String email,
    String? program,
    int? year,
  });

  Future<Either<Failure, bool>> removeStudent({
    required String collegeId,
    required String studentId,
  });

  Future<Either<Failure, List<CollegeWorkspaceEntity>>> listCollegeWorkspaces({
    int page,
    int size,
  });

  Future<Either<Failure, CollegeMetricsEntity>> getCollegeMetrics(
    String collegeId,
  );
}
