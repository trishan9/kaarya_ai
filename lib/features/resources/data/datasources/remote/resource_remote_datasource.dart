import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/features/resources/data/datasources/resource_datasource.dart';
import 'package:kaarya/features/resources/data/models/resource_course_api_model.dart';

final resourceRemoteDatasourceProvider = Provider<IResourceRemoteDataSource>((
  ref,
) {
  return ResourceRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class ResourceRemoteDataSource implements IResourceRemoteDataSource {
  final ApiClient _apiClient;

  ResourceRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<ResourceCoursesListApiResponse> listCourses({
    int page = 1,
    int size = 20,
    String? search,
    String? difficulty,
    String? category,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.resources,
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (difficulty != null && difficulty.trim().isNotEmpty)
          'difficulty': difficulty.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
      },
    );
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
        message: _nullableString(normalized['message']) ?? 'Request failed.',
      );
    }
    final rawData = normalized['data'];
    // API returns data as a plain list directly
    if (rawData is List) {
      return ResourceCoursesListApiResponse(
        courses: ResourceCourseApiModel.fromApiList(rawData),
        totalCount: rawData.length,
        page: 1,
        size: rawData.length,
      );
    }
    // API returns data as a map (containing resources/courses/totalCount/etc.)
    if (rawData is Map) {
      return ResourceCoursesListApiResponse.fromJson(_castMap(rawData));
    }
    return const ResourceCoursesListApiResponse(
      courses: [],
      totalCount: 0,
      page: 1,
      size: 20,
    );
  }

  @override
  Future<ResourceCourseApiModel> getCourseById(String courseId) async {
    final response = await _apiClient.get(ApiEndpoints.resourceById(courseId));
    final data = _extractDataMap(response);
    final resource = _asMap(data['resource']) ?? data;
    return ResourceCourseApiModel.fromApiResponse(resource);
  }

  @override
  Future<ResourceCourseApiModel> createCourse({
    required String title,
    String? description,
    required String category,
    required String generationMode,
    required String difficulty,
    required List<String> targetRoles,
    int? chapterCount,
    String? visibility,
    bool? includeVideoRecommendations,
    String? promptContext,
    String? jobDescriptionContext,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.resources,
      data: {
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        'category': category,
        'generationMode': generationMode,
        'difficulty': difficulty,
        'targetRoles': targetRoles,
        if (chapterCount != null) 'chapterCount': chapterCount,
        if (visibility != null) 'visibility': visibility,
        if (includeVideoRecommendations != null)
          'includeVideoRecommendations': includeVideoRecommendations,
        if (promptContext != null && promptContext.isNotEmpty)
          'promptContext': promptContext,
        if (jobDescriptionContext != null && jobDescriptionContext.isNotEmpty)
          'jobDescriptionContext': jobDescriptionContext,
      },
    );
    final data = _extractDataMap(response);
    final resource = _asMap(data['resource']) ?? data;
    return ResourceCourseApiModel.fromApiResponse(resource);
  }

  @override
  Future<ResourceCourseApiModel> updateCourse({
    required String courseId,
    required Map<String, dynamic> fields,
  }) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.resourceById(courseId),
      data: fields,
    );
    final data = _extractDataMap(response);
    final resource = _asMap(data['resource']) ?? data;
    return ResourceCourseApiModel.fromApiResponse(resource);
  }

  @override
  Future<bool> deleteCourse(String courseId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.resourceById(courseId),
    );
    final body = response.data;
    if (body is Map) {
      final normalized = _castMap(body);
      return normalized['success'] == true;
    }
    return false;
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

    final normalized = _castMap(body);
    if (normalized['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: _nullableString(normalized['message']) ?? 'Request failed.',
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

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return _castMap(value);
    return null;
  }

  String? _nullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }
}
