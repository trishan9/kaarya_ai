import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/leaderboard/data/datasources/leaderboard_datasource.dart';
import 'package:kaarya/features/leaderboard/data/models/leaderboard_api_model.dart';

final leaderboardRemoteDatasourceProvider =
    Provider<ILeaderboardRemoteDataSource>((ref) {
      return LeaderboardRemoteDataSource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class LeaderboardRemoteDataSource implements ILeaderboardRemoteDataSource {
  final ApiClient _apiClient;

  LeaderboardRemoteDataSource({required ApiClient apiClient})
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
  Future<LeaderboardApiModel> getLeaderboard({
    String? scope,
    String? collegeId,
    int? page,
    int? size,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.leaderboard,
      queryParameters: {
        if (scope != null && scope.isNotEmpty) 'scope': scope,
        if (collegeId != null && collegeId.isNotEmpty) 'collegeId': collegeId,
        if (page != null) 'page': page,
        if (size != null) 'size': size,
      },
    );

    final data = _extractDataMap(response);
    return LeaderboardApiModel.fromApiResponse(data);
  }
}
