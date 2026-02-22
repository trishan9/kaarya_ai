import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/bookmarks/data/datasources/bookmark_datasource.dart';
import 'package:kaarya/features/bookmarks/data/models/bookmarks_api_model.dart';

final bookmarkRemoteDatasourceProvider = Provider<IBookmarkRemoteDataSource>((
  ref,
) {
  return BookmarkRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class BookmarkRemoteDataSource implements IBookmarkRemoteDataSource {
  final ApiClient _apiClient;

  BookmarkRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Map<String, dynamic> _extractDataMap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return jsonCastMap(data['data'] as Map);
    }
    if (data is Map) return jsonCastMap(data);
    return const {};
  }

  @override
  Future<BookmarksApiModel> getMyBookmarks({
    String? type,
    String? search,
    String? sortBy,
    int? page,
    int? size,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.myBookmarks,
      queryParameters: {
        if (type != null && type.isNotEmpty) 'type': type,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
        if (page != null) 'page': page,
        if (size != null) 'size': size,
      },
    );

    final data = _extractDataMap(response);
    return BookmarksApiModel.fromApiResponse(data);
  }

  bool _isSuccessResponse(Response response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) return false;
    final body = response.data;
    if (body == null) return true; // e.g. 204 No Content
    if (body is! Map) return true; // 2xx with non-map body, assume success
    final map = jsonCastMap(body);
    if (map['success'] == false) return false;
    if (map['success'] == true) return true;
    final data = map['data'];
    if (data is Map) {
      final dataMap = jsonCastMap(data);
      if (dataMap['success'] == false) return false;
      if (dataMap['success'] == true) return true;
    }
    return true; // 2xx with no explicit failure
  }

  @override
  Future<bool> saveJobBookmark(String jobId) async {
    final response = await _apiClient.post(ApiEndpoints.bookmarkJob(jobId));
    return _isSuccessResponse(response);
  }

  @override
  Future<bool> unsaveJobBookmark(String jobId) async {
    final response = await _apiClient.delete(ApiEndpoints.bookmarkJob(jobId));
    return _isSuccessResponse(response);
  }

  @override
  Future<bool> saveInterviewBookmark(String interviewId) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookmarkInterview(interviewId),
    );
    return _isSuccessResponse(response);
  }

  @override
  Future<bool> unsaveInterviewBookmark(String interviewId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.bookmarkInterview(interviewId),
    );
    return _isSuccessResponse(response);
  }
}
