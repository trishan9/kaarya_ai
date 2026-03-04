import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/companies/data/datasources/company_datasource.dart';
import 'package:kaarya/features/companies/data/models/company_api_model.dart';

final companyRemoteDatasourceProvider = Provider<ICompanyRemoteDataSource>((
  ref,
) {
  return CompanyRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class CompanyRemoteDataSource implements ICompanyRemoteDataSource {
  final ApiClient _apiClient;

  CompanyRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<CompanyApiModel>> listCompanies({
    int page = 1,
    int size = 20,
    String? search,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.companies,
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final data = _extractDataMap(response);
    return CompanyApiModel.fromApiList(
      data['companies'] ?? data['data'] ?? data['items'],
    );
  }

  @override
  Future<CompanyApiModel> getCompanyById(String companyId) async {
    final response = await _apiClient.get(ApiEndpoints.companyById(companyId));
    final data = _extractDataMap(response);
    final company = jsonAsMap(data['company']) ?? data;
    return CompanyApiModel.fromJson(company);
  }

  @override
  Future<CompanyApiModel> createCompany({
    required String name,
    required String industry,
    required String location,
    String? logoPath,
    required String designation,
  }) async {
    late final Response response;

    if (logoPath != null && logoPath.isNotEmpty) {
      final formData = FormData.fromMap({
        'name': name,
        'industry': industry,
        'location': location,
        'designation': designation,
        'logo': await MultipartFile.fromFile(logoPath, filename: 'logo.jpg'),
      });
      response = await _apiClient.uploadFile(
        ApiEndpoints.companies,
        formData: formData,
      );
    } else {
      response = await _apiClient.post(
        ApiEndpoints.companies,
        data: {
          'name': name,
          'industry': industry,
          'location': location,
          'designation': designation,
        },
      );
    }

    final data = _extractDataMap(response);
    final company = jsonAsMap(data['company']) ?? data;
    return CompanyApiModel.fromJson(company);
  }

  @override
  Future<CompanyApiModel> updateCompany({
    required String companyId,
    required Map<String, dynamic> fields,
  }) async {
    late final Response response;

    final logoPath = fields['logoPath'] as String?;
    if (logoPath != null && logoPath.isNotEmpty) {
      final fieldsWithoutLogo = Map<String, dynamic>.from(fields)
        ..remove('logoPath');
      final formMap = <String, dynamic>{
        ...fieldsWithoutLogo,
        'logo': await MultipartFile.fromFile(logoPath, filename: 'logo.jpg'),
      };
      final formData = FormData.fromMap(formMap);
      response = await _apiClient.uploadFile(
        ApiEndpoints.companyById(companyId),
        formData: formData,
        options: Options(method: 'PATCH'),
      );
    } else {
      final cleanFields = Map<String, dynamic>.from(fields)..remove('logoPath');
      response = await _apiClient.put(
        ApiEndpoints.companyById(companyId),
        data: cleanFields,
      );
    }

    final data = _extractDataMap(response);
    final company = jsonAsMap(data['company']) ?? data;
    return CompanyApiModel.fromJson(company);
  }

  @override
  Future<bool> deleteCompany(String companyId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.companyById(companyId),
    );
    final body = response.data;
    if (body is Map) {
      return jsonCastMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<CompanyApiModel> joinByCode({
    required String inviteCode,
    required String designation,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.joinCompanyByCode,
      data: {'inviteCode': inviteCode, 'designation': designation},
    );
    final data = _extractDataMap(response);
    final company = jsonAsMap(data['company']) ?? data;
    return CompanyApiModel.fromJson(company);
  }

  @override
  Future<CompanyApiModel> resetInviteCode(String companyId) async {
    final response = await _apiClient.post(
      ApiEndpoints.companyResetInviteCode(companyId),
    );
    final data = _extractDataMap(response);
    final company = jsonAsMap(data['company']) ?? data;
    return CompanyApiModel.fromJson(company);
  }

  @override
  Future<List<WorkspaceMemberApiModel>> listRecruiters({
    required String companyId,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.companyRecruiters(companyId),
      queryParameters: {'page': page, 'size': size},
    );
    final data = _extractDataMap(response);
    return WorkspaceMemberApiModel.fromApiList(
      data['recruiters'] ?? data['members'] ?? data['data'] ?? data['items'],
    );
  }

  @override
  Future<bool> inviteRecruiter({
    required String companyId,
    required String email,
    required String designation,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.companyInviteRecruiter(companyId),
      data: {'email': email, 'designation': designation},
    );
    final body = response.data;
    if (body is Map) {
      return jsonCastMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<bool> removeRecruiter({
    required String companyId,
    required String recruiterId,
  }) async {
    final response = await _apiClient.delete(
      ApiEndpoints.removeRecruiter(companyId, recruiterId),
    );
    final body = response.data;
    if (body is Map) {
      return jsonCastMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<List<RecruiterWorkspaceApiModel>> listRecruiterWorkspaces({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.recruiterWorkspaces,
      queryParameters: {'page': page, 'size': size},
    );
    final data = _extractDataMap(response);
    return RecruiterWorkspaceApiModel.fromApiList(
      data['workspaces'] ?? data['data'] ?? data['items'],
    );
  }

  Map<String, dynamic> _extractDataMap(Response response) {
    final body = response.data;
    if (body is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid response payload.',
      );
    }

    final normalized = jsonCastMap(body);
    if (normalized['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: jsonNullableString(normalized['message']) ?? 'Request failed.',
      );
    }

    final data = normalized['data'];
    if (data is Map) {
      return jsonCastMap(data);
    }

    return <String, dynamic>{};
  }
}
