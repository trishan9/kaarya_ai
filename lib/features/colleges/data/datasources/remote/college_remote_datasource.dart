import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/colleges/data/datasources/college_datasource.dart';
import 'package:kaarya/features/colleges/data/models/college_api_model.dart';

final collegeRemoteDatasourceProvider = Provider<ICollegeRemoteDataSource>((
  ref,
) {
  return CollegeRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class CollegeRemoteDataSource implements ICollegeRemoteDataSource {
  final ApiClient _apiClient;

  CollegeRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<CollegeApiModel>> listColleges({
    int page = 1,
    int size = 20,
    String? search,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.colleges,
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final data = _extractDataMap(response);
    return CollegeApiModel.fromApiList(data['colleges']);
  }

  @override
  Future<CollegeApiModel> getCollegeById(String collegeId) async {
    final response = await _apiClient.get(ApiEndpoints.collegeById(collegeId));
    final data = _extractDataMap(response);
    final college = jsonAsMap(data['college']) ?? data;
    return CollegeApiModel.fromJson(college);
  }

  @override
  Future<CollegeApiModel> createCollege({
    required String name,
    required String institutionType,
    required String location,
    String? logoPath,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'institutionType': institutionType,
      'location': location,
      if (logoPath != null)
        'logo': await MultipartFile.fromFile(logoPath, filename: 'logo.png'),
    });

    final response = await _apiClient.uploadFile(
      ApiEndpoints.colleges,
      formData: formData,
    );
    final data = _extractDataMap(response);
    final college = jsonAsMap(data['college']) ?? data;
    return CollegeApiModel.fromJson(college);
  }

  @override
  Future<CollegeApiModel> updateCollege({
    required String collegeId,
    String? name,
    String? institutionType,
    String? location,
    String? logoPath,
  }) async {
    final fields = <String, dynamic>{
      if (name != null) 'name': name,
      if (institutionType != null) 'institutionType': institutionType,
      if (location != null) 'location': location,
    };

    if (logoPath != null) {
      fields['logo'] = await MultipartFile.fromFile(
        logoPath,
        filename: 'logo.png',
      );
    }

    final formData = FormData.fromMap(fields);

    final response = await _apiClient.uploadFile(
      ApiEndpoints.collegeById(collegeId),
      formData: formData,
      options: Options(method: 'PATCH'),
    );
    final data = _extractDataMap(response);
    final college = jsonAsMap(data['college']) ?? data;
    return CollegeApiModel.fromJson(college);
  }

  @override
  Future<bool> deleteCollege(String collegeId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.collegeById(collegeId),
    );
    final body = response.data;
    if (body is Map) {
      return _castMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<CollegeApiModel> joinByCode(String inviteCode) async {
    final response = await _apiClient.post(
      ApiEndpoints.joinCollegeByCode,
      data: {'inviteCode': inviteCode},
    );
    final data = _extractDataMap(response);
    final college = jsonAsMap(data['college']) ?? data;
    return CollegeApiModel.fromJson(college);
  }

  @override
  Future<String> resetInviteCode(String collegeId) async {
    final response = await _apiClient.post(
      ApiEndpoints.collegeResetInviteCode(collegeId),
    );
    final data = _extractDataMap(response);
    return jsonString(data['inviteCode']);
  }

  @override
  Future<List<StudentMemberApiModel>> listStudents({
    required String collegeId,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.collegeStudents(collegeId),
      queryParameters: {'page': page, 'size': size},
    );
    final data = _extractDataMap(response);
    return StudentMemberApiModel.fromApiList(
      data['students'] ?? data['members'],
    );
  }

  @override
  Future<bool> inviteStudent({
    required String collegeId,
    required String email,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.collegeInviteStudent(collegeId),
      data: {'email': email},
    );
    final body = response.data;
    if (body is Map) {
      return _castMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<bool> removeStudent({
    required String collegeId,
    required String studentId,
  }) async {
    final response = await _apiClient.delete(
      ApiEndpoints.removeStudent(collegeId, studentId),
    );
    final body = response.data;
    if (body is Map) {
      return _castMap(body)['success'] == true;
    }
    return false;
  }

  @override
  Future<List<CollegeWorkspaceApiModel>> listCollegeWorkspaces({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.collegeWorkspaces,
      queryParameters: {'page': page, 'size': size},
    );
    final data = _extractDataMap(response);
    return CollegeWorkspaceApiModel.fromApiList(
      data['workspaces'] ?? data['colleges'],
    );
  }

  @override
  Future<CollegeMetricsApiModel> getCollegeMetrics(String collegeId) async {
    final response = await _apiClient.get(
      ApiEndpoints.collegeMetrics(collegeId),
    );
    final data = _extractDataMap(response);
    final metrics = jsonAsMap(data['metrics']) ?? data;
    return CollegeMetricsApiModel.fromJson(metrics);
  }

  // ---- helpers ----

  Map<String, dynamic> _extractDataMap(Response response) {
    final body = response.data;
    if (body is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid response payload.',
      );
    }

    final normalized = _castMap(body);
    if (normalized['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: jsonNullableString(normalized['message']) ?? 'Request failed.',
      );
    }

    final data = normalized['data'];
    if (data is Map) {
      return _castMap(data);
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _castMap(Map value) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}
