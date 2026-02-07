import 'package:kaarya/features/companies/data/models/company_api_model.dart';
import 'package:kaarya/features/companies/data/models/company_hive_model.dart';

abstract interface class ICompanyRemoteDataSource {
  Future<List<CompanyApiModel>> listCompanies({
    int page,
    int size,
    String? search,
  });

  Future<CompanyApiModel> getCompanyById(String companyId);

  Future<CompanyApiModel> createCompany({
    required String name,
    required String industry,
    required String location,
    String? logoPath,
    required String designation,
  });

  Future<CompanyApiModel> updateCompany({
    required String companyId,
    required Map<String, dynamic> fields,
  });

  Future<bool> deleteCompany(String companyId);

  Future<CompanyApiModel> joinByCode({
    required String inviteCode,
    required String designation,
  });

  Future<CompanyApiModel> resetInviteCode(String companyId);

  Future<List<WorkspaceMemberApiModel>> listRecruiters({
    required String companyId,
    int page,
    int size,
  });

  Future<bool> inviteRecruiter({
    required String companyId,
    required String email,
    required String designation,
  });

  Future<bool> removeRecruiter({
    required String companyId,
    required String recruiterId,
  });

  Future<List<RecruiterWorkspaceApiModel>> listRecruiterWorkspaces({
    int page,
    int size,
  });
}

abstract interface class ICompanyLocalDataSource {
  Future<void> saveCompanies(List<CompanyHiveModel> data);
  Future<List<CompanyHiveModel>> listCompanies();

  Future<void> saveCompany(CompanyHiveModel data);
  Future<CompanyHiveModel?> getCompanyById(String companyId);

  Future<void> clearAll();
}
