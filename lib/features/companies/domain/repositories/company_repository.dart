import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/entities/recruiter_workspace_entity.dart';
import 'package:kaarya/features/companies/domain/entities/workspace_member_entity.dart';

abstract interface class ICompanyRepository {
  Future<Either<Failure, List<CompanyEntity>>> listCompanies({
    int page,
    int size,
    String? search,
  });

  Future<Either<Failure, CompanyEntity>> getCompanyById(String companyId);

  Future<Either<Failure, CompanyEntity>> createCompany({
    required String name,
    required String industry,
    required String location,
    String? logoPath,
    required String designation,
  });

  Future<Either<Failure, CompanyEntity>> updateCompany({
    required String companyId,
    required Map<String, dynamic> fields,
  });

  Future<Either<Failure, bool>> deleteCompany(String companyId);

  Future<Either<Failure, CompanyEntity>> joinByCode({
    required String inviteCode,
    required String designation,
  });

  Future<Either<Failure, CompanyEntity>> resetInviteCode(String companyId);

  Future<Either<Failure, List<WorkspaceMemberEntity>>> listRecruiters({
    required String companyId,
    int page,
    int size,
  });

  Future<Either<Failure, bool>> inviteRecruiter({
    required String companyId,
    required String email,
    required String designation,
  });

  Future<Either<Failure, bool>> removeRecruiter({
    required String companyId,
    required String recruiterId,
  });

  Future<Either<Failure, List<RecruiterWorkspaceEntity>>>
  listRecruiterWorkspaces({int page, int size});
}
