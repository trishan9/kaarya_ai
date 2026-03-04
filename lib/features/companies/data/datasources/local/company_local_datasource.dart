import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/hive/hive_service.dart';
import 'package:kaarya/features/companies/data/datasources/company_datasource.dart';
import 'package:kaarya/features/companies/data/models/company_hive_model.dart';

final companyLocalDatasourceProvider = Provider<ICompanyLocalDataSource>((ref) {
  return CompanyLocalDataSource(hiveService: ref.read(hiveServiceProvider));
});

class CompanyLocalDataSource implements ICompanyLocalDataSource {
  final HiveService _hiveService;

  CompanyLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveCompanies(List<CompanyHiveModel> data) async {
    await _hiveService.saveCompanies(data);
  }

  @override
  Future<List<CompanyHiveModel>> listCompanies() async {
    return _hiveService.listCompanies();
  }

  @override
  Future<void> saveCompany(CompanyHiveModel data) async {
    await _hiveService.saveCompany(data);
  }

  @override
  Future<CompanyHiveModel?> getCompanyById(String companyId) async {
    return _hiveService.getCompanyById(companyId);
  }

  @override
  Future<void> clearAll() async {
    await _hiveService.clearCompanies();
  }
}
